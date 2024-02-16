--[[
@ Name: Main loop
@ Date: 2024/02/10 (YYYY/MM/DD)
@ Author: okzyrox
\
--]]

-- Assets

local Assets = require 'assets.AssetList'

-- Import Screens
local SceneManager = require 'scenes.SceneManager'
local MainMenuScene = require 'scenes.MainMenu'
local MainScene = require 'scenes.MainScene'


debugging = true



function love.load()
    print("---")
    print("---Load Start---")

    -- Initialize game components
    sceneManager = SceneManager:new()
    -- Add screens to the manager
    sceneManager:add('menu', MainMenuScene:new())
    sceneManager:add('gameplay', MainScene:new())
    --sceneManager:add('lvledit', LevelEditorScreen:new())
    sceneManager:switch('menu', 1)


    assets = {
        images = {},
        music = {},
        sounds = {},
        fonts = {},

        models = {},
        textures = {}
    }

    LoadAssets()


    print("---Load End---")
end

function love.update(dt)

    sceneManager:update(dt)


    windowX, windowY = love.window.getPosition()

end


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
    if key == 'f2' then
        love.filesystem.createDirectory("Screenshots") -- create if not exists
        local dateTimeString = os.date('%Y-%m-%d_%H-%M-%S')
        local filename = "Screenshots/" .. "PKGAME-" .. dateTimeString .. ".png"
        love.graphics.captureScreenshot(filename)
        print("Screenshot saved as: " .. filename)
    end
end

function love.draw()

    sceneManager:draw()

end
