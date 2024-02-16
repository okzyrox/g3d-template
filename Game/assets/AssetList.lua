-- Asset List

-- Overwrite to love.audio to include some better stuff
require 'assets.SoundMod'
-- g3d
require 'library.g3d'


local function LoadSongs()

    -- love.audio.newSource(..., 'stream')

    --assets.music.<name> = love.audio.newSource('assets/music/<filename>', 'stream')

    print("Successfully loaded all Songs")
end

local function LoadSFX()

    -- love.audio.newSource(..., 'static')

    print("Successfully loaded all SFX")
end

local function LoadFonts()

    -- .love.graphics.newFont(..., fontSize)

    print("Successfully loaded all Fonts")
end

local function LoadImages()

    -- love.graphics.newImage(...)

    -- assets.images.grass_tile = love.graphics.newImage('assets/images/grass.png')

    print("Successfully loaded all Images")
end

function LoadTextures()

    assets.textures.blank = "assets/textures/blank.png"
    assets.textures.maptiles = "assets/textures/tileset.png"
    assets.textures.background = "assets/textures/starfield.png"


end

function LoadModels()

    assets.models.cube = "assets/models/cube.obj"
    assets.models.sphere = "assets/models/sphere.obj"

    assets.models.map = "assets/models/map.obj"
    

    print("Successfully loaded all Modles")
end



function LoadAssets()

    LoadSongs()
    LoadSFX()
    LoadFonts()
    LoadImages()
    LoadModels()
    LoadTextures()

    print("Sucessfully loaded all Assets!")

end