local TileManager = require 'world.TileManager'

local Entity = {}

function Entity:new(x, y, spriteMap, speed, width, height, zIndex, playerControllable, controlType)
    local obj = {
        x = x or 0,
        y = y or 0,
        spriteMap = spriteMap or nil,
        speed = speed or 100, -- speed modx
        width = width or 32,
        height = height or 32,
        zIndex = zIndex or 0,
        playerControllable = playerControllable or false,
        controlType = controlType or "1" -- keyboard scheme to control with, supports 2 entities
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Entity:update(dt, tiles)
    -- Update logic for the entity

    --[[
    if love.keyboard.isDown("left") then
        self.xVelocity = -self.speed
    elseif love.keyboard.isDown("right") then
        self.xVelocity = self.speed
    else
        self.xVelocity = 0
    end
    ]]

    local dx, dy = 0, 0

    if self.playerControllable then
        if self.controlType == "1" then
            if love.keyboard.isDown("a") then
                dx = -1
            elseif love.keyboard.isDown("d") then
                dx = 1
            end
            if love.keyboard.isDown("w") then
                dy = -1
            elseif love.keyboard.isDown("s") then
                dy = 1
            end
        else--[[if self.controlType == "2" then]]
            if love.keyboard.isDown("left") then
                dx = -1
            elseif love.keyboard.isDown("right") then
                dx = 1
            end
            if love.keyboard.isDown("up") then
                dy = -1
            elseif love.keyboard.isDown("down") then
                dy = 1
            end

        end
        
    
        -- Normalize diagonal movement
        if dx ~= 0 and dy ~= 0 then
            dx = dx * 0.7071
            dy = dy * 0.7071
        end
    
        -- Calculate new position
        local newX, newY = self.x + self.speed * dx * dt, self.y + self.speed * dy * dt
    
        -- Check for collisions with tiles
        for _, tile in ipairs(tiles) do
            if self:checkCollision(newX, newY, tile) then
                return -- Stop moving if collision detected
            end
        end
    
        -- Update position if no collision detected
        self.x, self.y = newX, newY
    end
    

    -- grav

    --[[
    self.yVelocity = self.yVelocity + self.gravity * dt

    -- Apply velocity
    self.x = self.x + self.xVelocity * dt
    self.y = self.y + self.yVelocity * dt

    -- Check for collisions with tiles below
    local futureY = self.y + self.yVelocity * dt
    for _, tile in ipairs(tiles) do
        if self:checkCollision(self.x, futureY + self.height, tile) then
            -- Collided with a tile below, stop falling and adjust position
            self.y = tile.y - self.height
            self.yVelocity = 0
            self.isGrounded = true
            break
        end
    end]]

    -- Check for jumping

    --[[
    if love.keyboard.isDown("space") and self.isGrounded then
        self.yVelocity = self.jumpHeight
    end

    ]]


    --[[
    if self.yVelocity ~= 0 then
        self.isGrounded = false
    end
    ]]
    
end

function Entity:draw()
    if self.spriteMap then
        local scaleX = self.width / self.spriteMap:getWidth()
        local scaleY = self.height / self.spriteMap:getHeight()

        love.graphics.draw(self.spriteMap, self.x, self.y, 0, scaleX, scaleY)
    else
        -- Draw a placeholder rectangle if no sprite map is provided
        love.graphics.rectangle("fill", self.x, self.y, 32, 32)
    end
end


function Entity:checkCollision(x, y, tile)
    -- Check if the entity collides with the tile

    
    local tileLeft = tile.x
    local tileRight = tile.x + tile.width
    local tileTop = tile.y
    local tileBottom = tile.y + tile.height

    -- Check if the entity's bounds overlap with the tile's bounds
    return x < tileRight and x + self.width > tileLeft and
           y < tileBottom and y + self.height > tileTop
    
end

return Entity
