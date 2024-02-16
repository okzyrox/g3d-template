local MenuScene = {}

function MenuScene:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function MenuScene:enter()
    -- Initialization code when entering the menu screen
end

function MenuScene:update(dt)
    -- Update logic for the menu screen
end

function MenuScene:draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Main Menu", 0, 100, love.graphics.getWidth(), "center")
    love.graphics.printf("Press Enter to start the game", 0, 150, love.graphics.getWidth(), "center")

    -- Display FPS
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Graphics Driver: " .. love.graphics.getRendererInfo(), 10, 30)
end

function MenuScene:keypressed(key)
    if key == 'return' then
        -- Switch to a different screen (e.g., 'gameplay')
        sceneManager:switch('gameplay', 1)
    end
end

function MenuScene:exit()
    -- Cleanup code when exiting the menu screen
end

return MenuScene