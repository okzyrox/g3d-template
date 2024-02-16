local g3d = require 'library.g3d'
local ModelManager = require 'world.ModelManager'
local utils = require 'utils.utils'

local Player = require "entities.Player"

local map, background, player
local canvas
local accumulator = 0
local frametime = 1/60
local rollingAverage = {}
local CurrentSong

local MainScene = {}

function MainScene:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function MainScene:enter()
    -- Initialization code when entering the scene

    modelManager = ModelManager:new()

    CurrentSong = "testbg"

    newModel = g3d.newModel(
        assets.models.cube,
        assets.textures.blank,
        {5, -5, 4},
        {0, 0, 0},
        {1, 1, 1}
    )

    love.graphics.setBackgroundColor(0.25,0.5,1)

    map = g3d.newModel(assets.models.map, assets.textures.maptiles, nil, nil, {-1,-1,1})
    background = g3d.newModel(assets.models.sphere, assets.textures.background, {0,0,0}, nil, {500,500,500})
    player = Player:new(0,0,0)
    

    canvas = {love.graphics.newCanvas(1280,720), depth=true}
    

    modelManager:add(newModel)
    modelManager:add(background)
    modelManager:add(map)
    
    local collideables =  {
        newModel,
        map
    }
    

    player:setCollisionModels(collideables)
    love.audio.play(assets.music.testbg)
end

function MainScene:update(dt)
    -- Update logic for the scene

    -- update Player
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
    end
end

function MainScene:draw()

    --love.graphics.setCanvas(canvas)
    --love.graphics.clear(0,0,0,0)

    modelManager:draw()

    
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)

    -- Display FPS
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Graphics Driver: " .. love.graphics.getRendererInfo(), 10, 30)
    love.graphics.print("--------------", 10, 50)
    love.graphics.print("PlayerX: " .. tostring(-utils:round(player.position[1])), 10, 70)
    love.graphics.print("PlayerY: " .. tostring(-utils:round(player.position[2])), 10, 90)
    love.graphics.print("PlayerZ: " .. tostring(-utils:round(player.position[3])), 10, 110)
    love.graphics.print("--------------", 10, 130)
    love.graphics.print("CurrentSong: " .. CurrentSong, 10, 150)


    --love.graphics.setCanvas()
    --love.graphics.draw(canvas[1], 1280/2, 720/2, 0, 1,-1, 1280/2, 720/2)

    
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