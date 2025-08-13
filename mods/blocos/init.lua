-- mods/blocos/init.lua

local Blocks = {}
local world = nil
local placedBlocks = {}
local blockImages = {}
local Inventory = nil
local validBlocks = {}

Blocks.api = {}

function Blocks.init(bumpWorld)
    world = bumpWorld
    Inventory = require("inventory")
    
    print("Módulo de blocos inicializado!")
    blockImages["terra"] = love.graphics.newImage("mods/blocos/textures/terra.png")
    blockImages["pedra"] = love.graphics.newImage("mods/blocos/textures/pedra.png")
    blockImages["madeira"] = love.graphics.newImage("mods/blocos/textures/madeira.png")
    blockImages["carvao"] = love.graphics.newImage("mods/blocos/textures/carvao.png")
    blockImages["areia"] = love.graphics.newImage("mods/blocos/textures/areia.png")
    blockImages["maca"] = love.graphics.newImage("mods/blocos/textures/maca.png")
    
    validBlocks["terra"] = true
    validBlocks["pedra"] = true
    validBlocks["madeira"] = true
    validBlocks["carvao"] = true
    validBlocks["areia"] = true
end

function Blocks.api.getImage(type)
    return blockImages[type]
end

function Blocks.api.isValidBlock(type)
    return validBlocks[type]
end

function Blocks.api:placeBlock(x, y, type)
    if not validBlocks[type] then
        print("Este item não pode ser colocado como um bloco!")
        return false
    end
    
    if Inventory.api.getItemCount(type) and Inventory.api.getItemCount(type) > 0 then
        if Inventory.api.removeItem(type, 1) then
            local newBlock = {
                x = x,
                y = y,
                type = type,
                image = blockImages[type]
            }
            
            table.insert(placedBlocks, newBlock)
            world:add(newBlock, x, y, 16, 16)
            
            print("Bloco de "..type.." colocado!")
            return true
        end
    end
    print("Sem bloco de "..type.." no inventário.")
    return false
end

function Blocks.api:draw()
    for _, block in ipairs(placedBlocks) do
        love.graphics.draw(block.image, block.x, block.y)
    end
end

-- AQUI: A função agora recebe o 'selectedItem' como parâmetro
function Blocks.api:pickupBlock(x, y, selectedItem)
    if not selectedItem then
        print("Selecione um item para pegar o bloco.")
        return false
    end

    local toolType = selectedItem.type

    for i, block in ipairs(placedBlocks) do
        if block.x == x and block.y == y then
            local canPickup = false
            if (block.type == "madeira" and toolType == "machado") or 
               (block.type == "pedra" and toolType == "picareta") or
               (block.type == "carvao" and toolType == "picareta") or
               (block.type == "terra" and (toolType == "pa" or not toolType)) or
               (block.type == "areia" and (toolType == "pa" or not toolType)) then
               canPickup = true
            end

            if canPickup then
                world:remove(block)
                table.remove(placedBlocks, i)
                Inventory.api.addItem(block.type, 1)
                print("Bloco de "..block.type.." pego!")
                return true
            else
                print("Ferramenta errada! Use a ferramenta correta para pegar o bloco.")
                return false
            end
        end
    end
    
    print("Nenhum bloco encontrado para pegar.")
    return false
end

return Blocks
