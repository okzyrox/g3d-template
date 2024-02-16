--[[
@ Name: Main loop
@ Author: okzyrox
\
--]]

-- Assets

local Assets = require 'assets.AssetList'

-- Import Screens
local SceneManager = require 'scenes.SceneManager'
local MainMenuScene = require 'scenes.MainMenu'
local MainScene = require 'scenes.MainScene'



function love.load()
    print("---")
    print("---Load Start---")

    -- Initialize game components
    sceneManager = SceneManager:new()
    -- Add screens to the manager
    -- When you make scenes, they have to be initialised in the scenemanager for them to be registered
    -- and also to give them a 'id', to be used when switching between scenes with :switch()
    sceneManager:add('menu', MainMenuScene:new())
    sceneManager:add('gameplay', MainScene:new()) 


    sceneManager:switch('menu', 1)


    assets = { -- asset index, can be extended as much as possible
        images = {},
        music = {},
        sounds = {},
        fonts = {},

        models = {},
        textures = {}
    }

    LoadAssets() -- load all assets


    print("---Load End---")
end

function love.update(dt)

    sceneManager:update(dt) -- Update scenes

end

-- When extending love modules, you can use them in scenes  with this:
--[[

function love.<module>(...)

    if sceneManager.currentScene and sceneManager.currentScene.<module> then
        sceneManager.currentScene:<module>(...)
    end
end
-- this simply checks if the current scene exists and that the current scene has the module,
-- if so then it runs it and passes any parameters down

]]
function love.textinput(text)

    if sceneManager.currentScene and sceneManager.currentScene.textinput then
        sceneManager.currentScene:textinput(text)
    end

end

function love.mousepressed(x, y, button, istouch, presses)
    -- If mouse clicked

    if sceneManager.currentScene and sceneManager.currentScene.mousepressed then
        sceneManager.currentScene:mousepressed(x, y, button, istouch, presses)
    end

end

function love.mousemoved(x,y, dx,dy)
    if sceneManager.currentScene and sceneManager.currentScene.mousemoved then
        sceneManager.currentScene:mousemoved(x, y, dx, dy)
    end
end


function love.wheelmoved(x, y)
    -- If mouse scrolled
    -- 1 = up
    -- -1 = down
    if sceneManager.currentScene and sceneManager.currentScene.wheelmoved then
        sceneManager.currentScene:wheelmoved(x, y)
    end
end

function love.keypressed(key)

    if sceneManager.currentScene and sceneManager.currentScene.keypressed then
        sceneManager.currentScene:keypressed(key)
    end

    -- Screenshots
    -- Anything that isnt in a scene can be activated globally,
    -- so this 'F2 for screenshot' feature can be used on any scene
    -- They are saved in /Appdata/Roaming/LOVE/<config.identity>/Screenshots
    if key == 'f2' then
        love.filesystem.createDirectory("Screenshots") -- create if not exists
        local dateTimeString = os.date('%Y-%m-%d_%H-%M-%S')
        local filename = "Screenshots/" .. "GameName-" .. dateTimeString .. ".png"
        love.graphics.captureScreenshot(filename)
        print("Screenshot saved as: " .. filename)
    end
end

function love.draw()

    sceneManager:draw()

end
