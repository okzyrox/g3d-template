local g3d = require 'library.g3d'
--local ModelManager = require 'world.ModelManager'
local utils = require 'utils.utils'

--local Player = require "entities.Player"
local Chunk = require 'world.Chunk'

local lume = require 'library.lume'

--local player

--threads
local size
local threadpool = {}
-- load up some threads so that chunk meshing won't block the main thread
for i=1, 8 do
    threadpool[i] = love.thread.newThread "library/chunkremesh.lua"
end
local threadchannels = {}
-- config
local texturepack 
local wasLeftDown, wasRightDown, rightDown, leftDown

local renderDistance = 5

-- create the mesh for the block cursor
local blockCursor, blockCursorVisible

do
    local a = -0.005
    local b = 1.005
    blockCursor = g3d.newModel{
        {a,a,a}, {b,a,a}, {b,a,a},
        {a,a,a}, {a,a,b}, {a,a,b},
        {b,a,b}, {a,a,b}, {a,a,b},
        {b,a,b}, {b,a,a}, {b,a,a},

        {a,b,a}, {b,b,a}, {b,b,a},
        {a,b,a}, {a,b,b}, {a,b,b},
        {b,b,b}, {a,b,b}, {a,b,b},
        {b,b,b}, {b,b,a}, {b,b,a},

        {a,a,a}, {a,b,a}, {a,b,a},
        {b,a,a}, {b,b,a}, {b,b,a},
        {a,a,b}, {a,b,b}, {a,b,b},
        {b,a,b}, {b,b,b}, {b,b,b},
    }
end


-- frame
local accumulator = 0
local frametime = 1/60
local rollingAverage = {}
-- music
local CurrentSong

local MainScene = {}

function MainScene:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function MainScene:addThing(thing)
    if not thing then return end
    table.insert(self.thingList, thing)
    return thing
end

function MainScene:removeThing(index)
    if not index then return end
    local thing = self.thingList[index]
    table.remove(self.thingList, index)
    return thing
end

local function updateChunk(self, x, y, z)
    x = x + math.floor(g3d.camera.position[1]/size)
    y = y + math.floor(g3d.camera.position[2]/size)
    z = z + math.floor(g3d.camera.position[3]/size)
    local hash = ("%d/%d/%d"):format(x, y, z)
    if self.chunkMap[hash] then
        self.chunkMap[hash].frames = 0
    else
        local chunk = Chunk:new(x, y, z)
        self.chunkMap[hash] = chunk
        self.chunkCreationsThisFrame = self.chunkCreationsThisFrame + 1

        -- this chunk was just created, so update all the chunks around it
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x+1,y,z)])
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x-1,y,z)])
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y+1,z)])
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y-1,z)])
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z+1)])
        self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z-1)])
    end
end

function MainScene:enter()
    -- Initialization code when entering the scene

    size = Chunk.size
    self.thingList = {}
    self.chunkMap = {}
    self.remeshQueue = {}
    self.chunkCreationsThisFrame = 0
    self.updatedThisFrame = false

    texturepack = assets.textures.voxeltextures

    --modelManager = ModelManager:new()

    CurrentSong = "testbg"

    
    --player:setCollisionModels(collideables)
    love.audio.play(assets.music.testbg)
end

function MainScene:update(dt)
    -- Update logic for the scene

    -- update things, remove dead things
    local i = 1
    while i <= #self.thingList do
        local thing = self.thingList[i]
        if not thing.dead then
            thing:update()
            i = i + 1
        else
            self:removeThing(i)
        end
    end

    self.updatedThisFrame = true

    --[[ -- update Player
    table.insert(rollingAverage, dt)
    if #rollingAverage > 60 then
        table.remove(rollingAverage, 1)
    end
    local avg = 0
    for i,v in ipairs(rollingAverage) do
        avg = avg + v
    end

    -- fixed timestep accumulator
    accumulator = accumulator + avg/#rollingAverage
    while accumulator > frametime do
        accumulator = accumulator - frametime
        player:update(dt)
    end

    -- interpolate player between frames
    -- to stop camera jitter when fps and timestep do not match
    player:interpolate(accumulator/frametime)

    if player.position[2] > 100 then -- higher number = lower pos because yea
        player.position[2] = -50
    end ]]

    -- generate a "bubble" of loaded chunks around the camera
    local bubbleWidth = renderDistance
    local bubbleHeight = math.floor(renderDistance * 0.75)
    local creationLimit = 1
    self.chunkCreationsThisFrame = 0
    for r=0, bubbleWidth do
        for a=0, math.pi*2, math.pi*2/(8*r) do
            local h = math.floor(math.cos(r*(math.pi/2)/bubbleWidth)*bubbleHeight + 0.5)
            for y=0, h do
                local x, z = math.floor(math.cos(a)*r + 0.5), math.floor(math.sin(a)*r + 0.5)
                if y ~= 0 then
                    updateChunk(self, x, -y, z)
                end
                updateChunk(self, x, y, z)
                if self.chunkCreationsThisFrame >= creationLimit then break end
            end
        end
    end

    -- count how many threads are being used right now
    local threadusage = 0
    for _, thread in ipairs(threadpool) do
        if thread:isRunning() then
            threadusage = threadusage + 1
        end

        local err = thread:getError()
        assert(not err, err)
    end

    -- listen for finished meshes on the thread channels
    for channel, chunk in pairs(threadchannels) do
        local data = love.thread.getChannel(channel):pop()
        if data then
            threadchannels[channel] = nil
            if chunk.model then chunk.model.mesh:release() end
            chunk.model = nil
            if data.count > 0 then
                chunk.model = g3d.newModel(data.count, texturepack)
                chunk.model.mesh:setVertices(data.data)
                chunk.model:setTranslation(chunk.x, chunk.y, chunk.z)
                chunk.inRemeshQueue = false
                break
            end
        end
    end

    -- remesh the chunks in the queue
    -- NOTE: if this happens multiple times in a frame, weird things can happen? idk why
    if threadusage < #threadpool and #self.remeshQueue > 0 then
        local chunk
        local ok = false
        repeat
            chunk = table.remove(self.remeshQueue, 1)
        until not chunk or self.chunkMap[chunk.hash]

        if chunk and not chunk.dead then
            for _, thread in ipairs(threadpool) do
                if not thread:isRunning() then
                    -- send over the neighboring chunks to the thread
                    -- so that voxels on the edges can face themselves properly
                    local x, y, z = chunk.cx, chunk.cy, chunk.cz
                    local neighbor, n1, n2, n3, n4, n5, n6
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x+1,y,z)]
                    if neighbor and not neighbor.dead then n1 = neighbor.data end
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x-1,y,z)]
                    if neighbor and not neighbor.dead then n2 = neighbor.data end
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x,y+1,z)]
                    if neighbor and not neighbor.dead then n3 = neighbor.data end
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x,y-1,z)]
                    if neighbor and not neighbor.dead then n4 = neighbor.data end
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x,y,z+1)]
                    if neighbor and not neighbor.dead then n5 = neighbor.data end
                    neighbor = self.chunkMap[("%d/%d/%d"):format(x,y,z-1)]
                    if neighbor and not neighbor.dead then n6 = neighbor.data end

                    thread:start(chunk.hash, chunk.data, n1, n2, n3, n4, n5, n6)
                    threadchannels[chunk.hash] = chunk
                    break
                end
            end
        end
    end

    -- left click to destroy blocks
    -- casts a ray from the camera five blocks in the look vector
    -- finds the first intersecting block
    local vx, vy, vz = g3d.camera.getLookVector()
    local x, y, z = g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]
    local step = 0.1
    local floor = math.floor
    local buildx, buildy, buildz
    blockCursorVisible = false
    for i=step, 5, step do
        local bx, by, bz = floor(x + vx*i), floor(y + vy*i), floor(z + vz*i)
        local chunk = self:getChunkFromWorld(bx, by, bz)
        if chunk then
            local lx, ly, lz = bx%size, by%size, bz%size
            if chunk:getBlock(self, lx,ly,lz) ~= 0 then
                blockCursor:setTranslation(bx, by, bz)
                blockCursorVisible = true

                -- store the last position the ray was at
                -- as the position for building a block
                local li = i - step
                buildx, buildy, buildz = floor(x + vx*li), floor(y + vy*li), floor(z + vz*li)

                if leftClick then
                    local x, y, z = chunk.cx, chunk.cy, chunk.cz
                    chunk:setBlock(self, lx,ly,lz, 0)
                    self:requestRemesh(chunk, true)
                    if lx >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x+1,y,z)], true) end
                    if lx <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x-1,y,z)], true) end
                    if ly >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y+1,z)], true) end
                    if ly <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y-1,z)], true) end
                    if lz >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z+1)], true) end
                    if lz <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z-1)], true) end
                end

                break
            end
        end
    end

    -- right click to place blocks
    if rightClick and buildx then
        local chunk = self:getChunkFromWorld(buildx, buildy, buildz)
        local lx, ly, lz = buildx%size, buildy%size, buildz%size
        if chunk then
            local x, y, z = chunk.cx, chunk.cy, chunk.cz
            chunk:setBlock(self, lx, ly, lz, 1)
            self:requestRemesh(chunk, true)
            if lx >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x+1,y,z)], true) end
            if lx <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x-1,y,z)], true) end
            if ly >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y+1,z)], true) end
            if ly <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y-1,z)], true) end
            if lz >= size-1 then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z+1)], true) end
            if lz <= 0      then self:requestRemesh(self.chunkMap[("%d/%d/%d"):format(x,y,z-1)], true) end
        end
    end
end

function MainScene:draw()

    --love.graphics.setCanvas(canvas)
    --love.graphics.clear(0,0,0,0)

    --modelManager:draw()

    love.graphics.clear(lume.color "#4488ff")

    -- draw all the things in the scene
    for _, thing in ipairs(self.thingList) do
        thing:draw()
    end

    love.graphics.setColor(1,1,1)
    for hash, chunk in pairs(self.chunkMap) do
        chunk:draw()

        if self.updatedThisFrame then
            chunk.frames = chunk.frames + 1
            if chunk.frames > 100 then chunk:destroy(self) end
        end
    end

    self.updatedThisFrame = false

    if blockCursorVisible then
        love.graphics.setColor(0,0,0)
        love.graphics.setWireframe(true)
        blockCursor:draw()
        love.graphics.setWireframe(false)
    end

    
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)

    -- Display FPS
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Graphics Driver: " .. love.graphics.getRendererInfo(), 10, 30)
    love.graphics.print("--------------", 10, 50)
    --[[
    love.graphics.print("PlayerX: " .. tostring(-utils:round(player.position[1])), 10, 70)
    love.graphics.print("PlayerY: " .. tostring(-utils:round(player.position[2])), 10, 90)
    love.graphics.print("PlayerZ: " .. tostring(-utils:round(player.position[3])), 10, 110)
    ]]
    love.graphics.print("--------------", 10, 130)
    love.graphics.print("CurrentSong: " .. CurrentSong, 10, 150)


    --love.graphics.setCanvas()
    --love.graphics.draw(canvas[1], 1280/2, 720/2, 0, 1,-1, 1280/2, 720/2)

    
end

function MainScene:getChunkFromWorld(x,y,z)
    local floor = math.floor
    return self.chunkMap[("%d/%d/%d"):format(floor(x/size),floor(y/size),floor(z/size))]
end

function MainScene:getBlockFromWorld(x,y,z)
    local floor = math.floor
    local chunk = self.chunkMap[("%d/%d/%d"):format(floor(x/size),floor(y/size),floor(z/size))]
    if chunk then return chunk:getBlock(self, x%size, y%size, z%size) end
    return -1
end

function MainScene:setBlockFromWorld(x,y,z, value)
    local floor = math.floor
    local chunk = self.chunkMap[("%d/%d/%d"):format(floor(x/size),floor(y/size),floor(z/size))]
    if chunk then chunk:setBlock(self, x%size, y%size, z%size, value) end
end

function MainScene:requestRemesh(chunk, first)
    -- don't add a nil chunk or a chunk that's already in the queue
    if not chunk then return end
    local x, y, z = chunk.cx, chunk.cy, chunk.cz
    if not self.chunkMap[("%d/%d/%d"):format(x+1,y,z)] then return end
    if not self.chunkMap[("%d/%d/%d"):format(x-1,y,z)] then return end
    if not self.chunkMap[("%d/%d/%d"):format(x,y+1,z)] then return end
    if not self.chunkMap[("%d/%d/%d"):format(x,y-1,z)] then return end
    if not self.chunkMap[("%d/%d/%d"):format(x,y,z+1)] then return end
    if not self.chunkMap[("%d/%d/%d"):format(x,y,z-1)] then return end
    chunk.inRemeshQueue = true
    if first then
        table.insert(self.remeshQueue, 1, chunk)
    else
        table.insert(self.remeshQueue, chunk)
    end
end


function MainScene:mousemoved(x, y, dx, dy)
    g3d.camera.firstPersonLook(dx,dy)
end

function MainScene:keypressed(key)
    if key == 'escape' then
        -- Switch to a different screen (e.g., 'gameplay')
        love.event.push('quit')
    elseif key == '1' then
        love.audio.stopAll()
        love.audio.play(assets.music.testbg)
        CurrentSong = "testbg"
    elseif key == 'm' then
        love.audio.stopAll()
        CurrentSong = "none"
    elseif key == 'c' then
        g3d.camera.capturingMouse = not g3d.camera.capturingMouse
    end
end

function MainScene:exit()
    -- Cleanup code when exiting the menu screen
end

return MainScene