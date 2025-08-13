-- mods/tools/init.lua

local Tools = {}
Tools.api = {}
local toolImages = {}

function Tools.load()
    toolImages.machado = love.graphics.newImage("mods/tools/textures/machado.png")
    toolImages.picareta = love.graphics.newImage("mods/tools/textures/picareta.png")
    toolImages.pa = love.graphics.newImage("mods/tools/textures/pa.png")
    -- Load all tool images here
end

function Tools.api.getDamage(toolType)
    if toolType == "machado" then return 10
    elseif toolType == "picareta" then return 8
    elseif toolType == "pa" then return 6
    end
end

function Tools.api.getImage(toolType)
    return toolImages[toolType]
end

return Tools
