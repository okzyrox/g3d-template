local ModelManager = {}

function ModelManager:new()
    local obj = {
        models = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ModelManager:add(model)
    table.insert(self.models, model)
end

function ModelManager:empty()
    self.models = {}
end

function ModelManager:update(dt)
    -- Update logic for models if needed
end

function ModelManager:draw()
    --table.sort(self.tiles, function(a, b) return a.zIndex < b.zIndex end)

    for _, model in ipairs(self.models) do
        model:draw()
    end
end

return ModelManager
