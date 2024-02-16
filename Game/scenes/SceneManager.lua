local TransitionScreen = require 'scenes.TransitionScreen'
local SceneManager = {}

function SceneManager:new()
    local obj = {
        scenes = {},
        currentScene = nil,
        transition = nil
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function SceneManager:switch(sceneName, transitionDuration)
    if self.currentScene then
        self.transition = TransitionScreen:new(transitionDuration, function()
            self.currentScene = self.scenes[sceneName]
            self.currentScene:enter()
            self.transition = TransitionScreen:new(transitionDuration, function() self.transition = nil end, "in")
        end)
    else
        self.currentScene = self.scenes[sceneName]
        self.currentScene:enter()
        self.transition = TransitionScreen:new(transitionDuration, function() self.transition = nil end, "in")
    end
end

function SceneManager:update(dt)
    if self.transition then
        self.transition:update(dt)
    elseif self.currentScene then
        self.currentScene:update(dt)
    end
end

function SceneManager:draw()
    if self.transition then
        self.transition:draw()
    elseif self.currentScene then
        self.currentScene:draw()
    end
end

function SceneManager:add(sceneName, scene)
    self.scenes[sceneName] = scene
end

return SceneManager
