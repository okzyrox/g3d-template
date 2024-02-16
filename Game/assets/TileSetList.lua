-- TileSetList

local TileSet = require 'world.TileSet'

local sets = {
    "cave_set",
    "world_set",
    "interior_set",
    -- etc
}

TileSets = {
    -- row 1
    
    r1CaveTile1 = TileSet:create(0, 0, 15, 15, "cave_set"),
    r1CaveTile2 = TileSet:create(16, 0, 15, 15, "cave_set"),
    r1CaveTile3 = TileSet:create(32, 0, 15, 15, "cave_set"),
    r1CaveTile4 = TileSet:create(48, 0, 15, 15, "cave_set"),
    r1CaveTile5 = TileSet:create(64, 0, 15, 15, "cave_set"),
    r1CaveTile6 = TileSet:create(80, 0, 15, 15, "cave_set"),

    --r2

    r2CaveTile1 = TileSet:create(0, 16, 15, 15, "cave_set"),
    r2CaveTile2 = TileSet:create(16, 16, 15, 15, "cave_set"),
    r2CaveTile3 = TileSet:create(32, 16, 15, 15, "cave_set"),
    r2CaveTile4 = TileSet:create(48, 16, 15, 15, "cave_set"),
    r2CaveTile5 = TileSet:create(64, 16, 15, 15, "cave_set"),
    r2CaveTile6 = TileSet:create(80, 16, 15, 15, "cave_set"),

    -- r3

    r3CaveTile1 = TileSet:create(0, 32, 15, 15, "cave_set"),
    r3CaveTile2 = TileSet:create(16, 32, 15, 15, "cave_set"),
    r3CaveTile3 = TileSet:create(32, 32, 15, 15, "cave_set"),
    r3CaveTile4 = TileSet:create(48, 32, 15, 15, "cave_set"),
    r3CaveTile5 = TileSet:create(64, 32, 15, 15, "cave_set"),
    r3CaveTile6 = TileSet:create(80, 32, 15, 15, "cave_set")
}

return TileSets