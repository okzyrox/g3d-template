EmptyScene = {}

function EmptyScene:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function EmptyScene:enter()
    -- Initialization code when entering the scene
    -- similar to the love.load() function, but only when the scene is being switched to
end

function EmptyScene:update(dt)
    -- Update logic for the scene
end

function EmptyScene:draw()
    -- All the drawing for your specific scene happens here
end

function EmptyScene:keypressed(key)
    -- Run keybinds
end

function EmptyScene:exit()
    -- Cleanup code when exiting the menu screen
end

return EmptyScene