-- mods/hotbar/init.lua
local Hotbar = {}
Hotbar.api = {}

local Inventory = nil
local Blocks = nil
local Tools = nil

local selectedSlot = 1
local numSlots = 5

function Hotbar.init(inventoryModule, blocksModule, toolsModule)
    Inventory = inventoryModule
    Blocks = blocksModule
    Tools = toolsModule
    print("Módulo de Hotbar inicializado!")
end

function Hotbar.api:selectSlot(slot)
    selectedSlot = slot
end

function Hotbar.api:getSelectedItem()
    -- AQUI: Chama a nova função getSlot do inventário
    return Inventory.api.getSlot(selectedSlot)
end

function Hotbar.api:draw()
    local screenW = love.graphics.getWidth()
    local startX = (screenW / 2) - ((numSlots * 32) / 2)
    local startY = love.graphics.getHeight() - 40
    
    for i = 1, numSlots do
        local x = startX + ((i - 1) * 32)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", x, startY, 32, 32)
        
        if i == selectedSlot then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", x - 2, startY - 2, 36, 36)
        end
        
        local slot = Inventory.api.getSlot(i)
        if slot and slot.item then
            local image = nil
            
            if Blocks.api.getImage(slot.item) then
                image = Blocks.api.getImage(slot.item)
            elseif Tools.api.getImage(slot.item) then
                image = Tools.api.getImage(slot.item)
            end
            
            if image then
                love.graphics.draw(image, x, startY)
            end
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(slot.count, x + 2, startY + 20)
        end
    end
end

return Hotbar
