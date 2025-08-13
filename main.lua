-- /main.lua
love.filesystem.setRequirePath("lib/?.lua;lib/?/init.lua;mods/?/init.lua;mods/?/textures/?.png")

local bump = require("bump")
local gamestate = require("gamestate")
local Camera = require("camera")

local Animation = require("animation")
local Blocks = require("blocos")
local Decor = require("decor")
local Flowers = require("flowers")
local Player = require("player")
local Tools = require("tools")
local Inventory = require("inventory")
local Hotbar = require("hotbar")
local Health = require("health")
local Inimigos = require("inimigos")
local deathInfo = nil

local myPlayer
local world
local mapa_fundo_img
local cam = Camera()

-- AQUI: Tabela para armazenar os itens largados no chão
local droppedItems = {}

local function playerAttack()
    if not myPlayer.isDead then
        local playerX, playerY = myPlayer:getPos()
        local attackRange = 20
        local attackDamage = 5 -- Dano padrão quando não há ferramenta

        local selectedItem = Hotbar.api:getSelectedItem()
        
        if selectedItem and selectedItem.item then
            local toolDamageValue = Tools.api.getDamage(selectedItem.item)
            if toolDamageValue ~= nil and toolDamageValue > 0 then
                attackDamage = toolDamageValue
            end
        end

        local enemies = Inimigos.api:getEnemies()

        for _, enemy in ipairs(enemies) do
            local dx = enemy.x - playerX
            local dy = enemy.y - playerY
            local distance = math.sqrt(dx^2 + dy^2)

            if distance < attackRange then
                enemy:takeDamage(attackDamage)
            end
        end
    end
end

local function setDeathInfo(info)
    deathInfo = info
end
Player.setDeathInfo = setDeathInfo

function love.load()
    mapa_fundo_img = love.graphics.newImage("mods/ui/textures/mapa_fundo.png")
    world = bump.newWorld(16)
    
    Blocks.init(world)
    Tools.load()
    Decor.init()
    
    Inventory.init(Blocks, Tools, Decor)
    Hotbar.init(Inventory, Blocks, Tools)

    Player.init(world, Hotbar, Tools, setDeathInfo)
    myPlayer = Player.new(100, 100)
    
    Health.init(myPlayer)
    
    Inimigos.init(world, myPlayer, Health)
    Inimigos.new(200, 200)
    
    world:add(myPlayer, myPlayer.x, myPlayer.y, myPlayer.largura, myPlayer.altura)
    Flowers:load()

    Inventory.api.addItem("terra", 5)
    Inventory.api.addItem("pedra", 3)
    Inventory.api.addItem("madeira", 10)
    Inventory.api.addItem("carvao", 5)
    Inventory.api.addItem("areia", 5)
    Inventory.api.addItem("maca", 3)
    Inventory.api.addItem("machado", 1)
    Inventory.api.addItem("picareta", 1)
    Inventory.api.addItem("pa", 1)
    Inventory.api.addItem("cadeira", 2)
    
    cam:zoomTo(2)
end

function love.update(dt)
    if not myPlayer.isDead then
        myPlayer:update(dt)
        for _, enemy in ipairs(Inimigos.api:getEnemies()) do
            enemy:update(dt)
        end
    end
    
    cam:lookAt(myPlayer.x, myPlayer.y)

    if not myPlayer.isDead and love.keyboard.isDown("k") then
        Health.api:takeDamage(1)
    end
end

function love.mousepressed(x, y, button)
    if not myPlayer.isDead then
        local worldX, worldY = cam:mousePosition()
        local gridX = math.floor(worldX / 16) * 16
        local gridY = math.floor(worldY / 16) * 16

        if Inventory.api.isOpen() then
            if button == 1 then
                local slotIndex = Inventory.api.getSlotAtPosition(x, y)
                if slotIndex then
                    Inventory.api.pickupItem(slotIndex)
                end
            end
        else
            if button == 1 then
                local selectedItem = Hotbar.api:getSelectedItem()
                if selectedItem and selectedItem.item and Tools.api.getDamage(selectedItem.item) then
                    playerAttack()
                else
                    Blocks.api:pickupBlock(gridX, gridY, selectedItem)
                end
            elseif button == 2 then
                local selectedItem = Hotbar.api:getSelectedItem()
                if selectedItem and selectedItem.item then
                    local itemType = selectedItem.item
                    if Blocks.api.isValidBlock(itemType) then
                        Blocks.api:placeBlock(gridX, gridY, itemType)
                    elseif Decor.api.isValidDecor(itemType) then
                        Decor.api:placeDecor(gridX, gridY, itemType)
                    else
                        print("Este item não pode ser colocado aqui.")
                    end
                end
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if not myPlayer.isDead and Inventory.api.isOpen() and Inventory.api.getHeldItem() then
        if button == 1 then
            local slotIndex = Inventory.api.getSlotAtPosition(x, y)
            
            -- AQUI: A nova lógica de dropItem.
            -- Agora ela lida com todos os casos.
            local dropped = Inventory.api.dropItem(slotIndex, myPlayer.x, myPlayer.y)
            if dropped then
                table.insert(droppedItems, {
                    item = dropped.item,
                    count = dropped.count,
                    x = myPlayer.x,
                    y = myPlayer.y
                })
            end
        end
    end
end


function love.keypressed(key)
    if key == 'i' then
        Inventory.api.toggle()
    end
    
    if not myPlayer.isDead then
        if key == '1' then Hotbar.api:selectSlot(1) end
        if key == '2' then Hotbar.api:selectSlot(2) end
        if key == '3' then Hotbar.api:selectSlot(3) end
        if key == '4' then Hotbar.api:selectSlot(4) end
        if key == '5' then Hotbar.api:selectSlot(5) end
        
        if key == 'q' then
            local selectedItem = Hotbar.api:getSelectedItem()
            if selectedItem and selectedItem.item == "maca" then
                if Inventory.api.removeItem("maca", 1) then
                    Health.api:heal(20)
                    print("Você comeu uma maçã e se curou!")
                else
                    print("Você não tem mais maçãs.")
                end
            else
                print("O item selecionado não é uma maçã.")
            end
        end

        if key == 'c' or key == 'lctrl' or key == 'rctrl' then
            playerAttack()
        end
    end

    if key == 'kp+' or key == '+' then
        cam:zoomTo(cam.scale * 1.1)
    end
    if key == 'kp-' or key == '-' then
        cam:zoomTo(cam.scale * 0.9)
    end
    
    if key == 'r' then
        if myPlayer.isDead then
            myPlayer:respawn(100, 100)
            Health.api:resetHealth()
        end
    end
end

function love.draw()
    cam:attach()
    love.graphics.draw(mapa_fundo_img, 0, 0)
    Blocks.api:draw()
    Decor.api:draw()
    Flowers:draw()
    
    -- AQUI: Desenha os itens largados no chão
    for _, item in ipairs(droppedItems) do
        local image = nil
        if Blocks.api.getImage(item.item) then
            image = Blocks.api.getImage(item.item)
        elseif Tools.api.getImage(item.item) then
            image = Tools.api.getImage(item.item)
        elseif Decor.api.getImage(item.item) then
            image = Decor.api.getImage(item.item)
        end
        if image then
            love.graphics.draw(image, item.x, item.y)
        end
    end
    
    myPlayer:draw()
    for _, enemy in ipairs(Inimigos.api:getEnemies()) do
        enemy:draw()
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Player X: " .. math.floor(myPlayer.x), myPlayer.x + 20, myPlayer.y)
    love.graphics.print("Player Y: " .. math.floor(myPlayer.y), myPlayer.x + 20, myPlayer.y + 10)
    
    cam:detach()
    
    Inventory.api:draw()
    Hotbar.api:draw()
    Health.api:draw()
    
    Inventory.api.drawHeldItem()
    
    if myPlayer.isDead and deathInfo then
        local screenW = love.graphics.getWidth()
        local screenH = love.graphics.getHeight()
        
        local boxW = 300
        local boxH = 100
        local boxX = (screenW - boxW) / 2
        local boxY = (screenH - boxH) / 2
        
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
        
        love.graphics.setColor(1, 0, 0, 1)
        local deathMessage = "Você morreu!"
        love.graphics.printf(deathMessage, boxX, boxY + 15, boxW, "center")
        
        love.graphics.setColor(1, 1, 1, 1)
        local positionMessage = "Posição: (" .. math.floor(deathInfo.x) .. ", " .. math.floor(deathInfo.y) .. ")"
        love.graphics.printf(positionMessage, boxX, boxY + 45, boxW, "center")
        
        local respawnMessage = "Pressione R para ressuscitar."
        love.graphics.printf(respawnMessage, boxX, boxY + 70, boxW, "center")
    end
end

return gamestate
