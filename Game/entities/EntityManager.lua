local EntityManager = {}

function EntityManager:new()
    local obj = {
        entities = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function EntityManager:add(entity)
    table.insert(self.entities, entity)
end

function EntityManager:update(dt, tiles)
    for _, entity in ipairs(self.entities) do
        entity:update(dt, tiles)
    end
end

function EntityManager:draw()
    table.sort(self.entities, function(a, b) return a.zIndex < b.zIndex end)

    for _, entity in ipairs(self.entities) do
        entity:draw()

        if showEntityHitboxes then
            love.graphics.setColor(1, 1, 0, 0.5) 
            love.graphics.rectangle("fill", entity.x, entity.y, entity.width, entity.height)
            love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
        end
    end
end

return EntityManager
