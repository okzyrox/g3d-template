local TransitionScreen = {}

function TransitionScreen:new(duration, onTransitionComplete, fadeType)
    local obj = {
        duration = duration or 1, -- Duration of the transition in seconds
        timer = 0,
        onComplete = onTransitionComplete or function() end,
        fadeType = fadeType or "out"
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function TransitionScreen:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.duration then
        self.onComplete()
    end
end

function TransitionScreen:draw()
    local alpha
    if self.fadeType == "out" then
        alpha = math.min(self.timer / self.duration, 1)
    else
        alpha = 1 - math.min(self.timer / self.duration, 1)
    end

    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

return TransitionScreen
