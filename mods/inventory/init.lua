-- mods/inventory/init.lua
local Inventory = {}
Inventory.api = {}

local InventorySlots = {}
local isVisible = false
local HeldItem = nil

local Blocks = nil
local Tools = nil
local Decor = nil

function Inventory.init(blocksModule, toolsModule, decorModule)
    Blocks = blocksModule
    Tools = toolsModule
    Decor = decorModule
    print("Módulo de inventário inicializado!")

    for i = 1, 30 do
        InventorySlots[i] = {
            item = nil,
            count = 0
        }
    end
end

function Inventory.api.isOpen()
    return isVisible
end

function Inventory.api.toggle()
    isVisible = not isVisible
end

function Inventory.api.getSlotAtPosition(x, y)
    local startX = (love.graphics.getWidth() / 2) - 160
    local startY = (love.graphics.getHeight() / 2) - 100
    local endX = startX + 320
    local endY = startY + 200

    if x >= startX and x <= endX and y >= startY and y <= endY then
        local slotX = math.floor((x - startX) / 32)
        local slotY = math.floor((y - startY) / 32)
        local slotIndex = (slotY * 10) + slotX + 1
        return slotIndex
    end
    return nil
end

function Inventory.api.getSlot(index)
    return InventorySlots[index]
end

function Inventory.api.getItemCount(itemType)
    local total = 0
    for _, slot in ipairs(InventorySlots) do
        if slot.item == itemType then
            total = total + slot.count
        end
    end
    return total
end

function Inventory.api.addItem(itemType, count)
    -- Tenta empilhar o item em um slot existente
    for _, slot in ipairs(InventorySlots) do
        if slot.item == itemType and slot.count < 64 then
            slot.count = slot.count + count
            if slot.count > 64 then
                local remaining = slot.count - 64
                slot.count = 64
                return Inventory.api.addItem(itemType, remaining)
            end
            return true
        end
    end

    -- Se não houver slots para empilhar, procura um slot vazio
    for _, slot in ipairs(InventorySlots) do
        if slot.item == nil then
            slot.item = itemType
            slot.count = count
            return true
        end
    end
    return false
end

function Inventory.api.removeItem(itemType, count)
    local total = Inventory.api.getItemCount(itemType)
    if total < count then
        return false
    end

    local remaining = count
    for _, slot in ipairs(InventorySlots) do
        if slot.item == itemType and remaining > 0 then
            if slot.count >= remaining then
                slot.count = slot.count - remaining
                if slot.count == 0 then
                    slot.item = nil
                end
                remaining = 0
            else
                remaining = remaining - slot.count
                slot.item = nil
                slot.count = 0
            end
        end
    end
    return true
end

function Inventory.api.pickupItem(slotIndex)
    local slot = InventorySlots[slotIndex]
    if slot and slot.item then
        if HeldItem then
            -- Troca de itens
            local tempItem = HeldItem.item
            local tempCount = HeldItem.count
            HeldItem.item = slot.item
            HeldItem.count = slot.count
            slot.item = tempItem
            slot.count = tempCount
        else
            -- Pega o item do slot
            HeldItem = {item = slot.item, count = slot.count}
            slot.item = nil
            slot.count = 0
        end
    elseif HeldItem then
        -- Coloca o item do mouse no slot vazio
        slot.item = HeldItem.item
        slot.count = HeldItem.count
        HeldItem = nil
    end
end

-- AQUI: A lógica da função dropItem foi corrigida e simplificada.
function Inventory.api.dropItem(slotIndex, playerX, playerY)
    if not HeldItem then
        return
    end

    if slotIndex then
        local slot = InventorySlots[slotIndex]
        if slot.item == HeldItem.item then
            local total = slot.count + HeldItem.count
            if total <= 64 then
                slot.count = total
                HeldItem = nil
            else
                slot.count = 64
                HeldItem.count = total - 64
            end
        elseif not slot.item then
            -- Se o slot estiver vazio
            slot.item = HeldItem.item
            slot.count = HeldItem.count
            HeldItem = nil
        else
            -- AQUI: NOVA LÓGICA - Troca de itens
            local tempHeldItem = { item = slot.item, count = slot.count }
            slot.item = HeldItem.item
            slot.count = HeldItem.count
            HeldItem = tempHeldItem
        end
    else
        -- Largando no chão
        Inventory.api.dropHeldItemOnGround(playerX, playerY)
    end
end

function Inventory.api.getHeldItem()
    return HeldItem
end

-- AQUI: Nova função para largar o item no chão (será chamada pelo main.lua)
function Inventory.api.dropHeldItemOnGround(x, y)
    if HeldItem then
        -- Adicionamos a lógica de drop ao main.lua, por isso não faremos nada aqui.
        local dropped = HeldItem
        HeldItem = nil
        print("Item "..dropped.item.." largado no chão! (count: "..dropped.count..")")
        return dropped
    end
    return nil
end

function Inventory.api.draw()
    if isVisible then
        local screenW = love.graphics.getWidth()
        local screenH = love.graphics.getHeight()
        local startX = (screenW / 2) - 160
        local startY = (screenH / 2) - 100
        
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", startX, startY, 320, 200)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", startX, startY, 320, 200)

        for i = 1, #InventorySlots do
            local slot = InventorySlots[i]
            local slotX = ((i - 1) % 10) * 32 + startX
            local slotY = math.floor((i - 1) / 10) * 32 + startY
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", slotX, slotY, 32, 32)
            
            if slot.item then
                local image = nil
                
                if Blocks.api.getImage(slot.item) then
                    image = Blocks.api.getImage(slot.item)
                elseif Tools.api.getImage(slot.item) then
                    image = Tools.api.getImage(slot.item)
                elseif Decor.api.getImage(slot.item) then
                    image = Decor.api.getImage(slot.item)
                end

                if image then
                    love.graphics.draw(image, slotX, slotY)
                end
                
                love.graphics.print(slot.count, slotX + 2, slotY + 20)
            end
        end
    end
end

function Inventory.api.drawHeldItem()
    if HeldItem and HeldItem.item then
        local mouseX = love.mouse.getX()
        local mouseY = love.mouse.getY()
        
        local image = nil
        if Blocks.api.getImage(HeldItem.item) then
            image = Blocks.api.getImage(HeldItem.item)
        elseif Tools.api.getImage(HeldItem.item) then
            image = Tools.api.getImage(HeldItem.item)
        elseif Decor.api.getImage(HeldItem.item) then
            image = Decor.api.getImage(HeldItem.item)
        end
        
        if image then
            love.graphics.draw(image, mouseX - 16, mouseY - 16)
        end
        
        love.graphics.print(HeldItem.count, mouseX, mouseY + 10)
    end
end

return Inventory
