-- mods/decor/init.lua
local Decor = {}
Decor.api = {}

local placedDecor = {}
local decorImages = {}
local Inventory = nil

function Decor.init(inventoryModule)
    Inventory = inventoryModule
    print("Módulo de decoração inicializado!")
    -- AQUI: Carregue as imagens dos seus itens de decoração
    decorImages["cadeira"] = love.graphics.newImage("mods/decor/textures/chair.png")
    -- Adicione mais itens aqui
end

function Decor.api.getImage(type)
    return decorImages[type]
end

function Decor.api.isValidDecor(type)
    return decorImages[type] ~= nil
end

function Decor.api:placeDecor(x, y, type)
    if not Decor.api.isValidDecor(type) then
        print("Este item não é um objeto de decoração!")
        return false
    end
    
    if Inventory.api.getItemCount(type) and Inventory.api.getItemCount(type) > 0 then
        if Inventory.api.removeItem(type, 1) then
            local newDecor = {
                x = x,
                y = y,
                type = type,
                image = decorImages[type]
            }
            
            table.insert(placedDecor, newDecor)
            print("Item de decoração de "..type.." colocado!")
            return true
        end
    end
    print("Sem item de decoração de "..type.." no inventário.")
    return false
end

function Decor.api:draw()
    for _, decor in ipairs(placedDecor) do
        love.graphics.draw(decor.image, decor.x, decor.y)
    end
end

return Decor
