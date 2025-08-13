-- mods/player/init.lua

local Player = {}
local world = nil
local Hotbar = nil
local Tools = nil
local setDeathInfo = nil

local Animation = require("animation")

function Player.init(bumpWorld, hotbarModule, toolsModule, deathInfoFunc)
    world = bumpWorld
    Hotbar = hotbarModule
    Tools = toolsModule
    setDeathInfo = deathInfoFunc
    print("Módulo de jogador inicializado.")
end

function Player.new(x, y)
    local self = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        flip_h = 1,
        largura = 16,
        altura = 16,
        origemX = 16 / 2,
        origemY = 16 / 2,
        speed = 150,
        isDead = false,
        animParado = Animation.new(love.graphics.newImage("mods/player/textures/player_stand.png"), 16, 16, 0.2, 4),
        animCorrendo = Animation.new(love.graphics.newImage("mods/player/textures/player_run.png"), 16, 16, 0.1, 4),
        classe = "player",
    }
    
    function self:getPos()
        return self.x, self.y
    end

    function self:die()
        if not self.isDead then
            self.isDead = true
            setDeathInfo({x = self.x, y = self.y})
            print("O jogador morreu!")
        end
    end

    function self:respawn(x, y)
        self.isDead = false
        self.x = x
        self.y = y
        self.vx = 0
        self.vy = 0
        setDeathInfo(nil)
        print("O jogador ressuscitou em (" .. x .. ", " .. y .. ")")
    end
    
    function self:update(dt)
        if self.isDead then return end
        
        self.vx = 0
        self.vy = 0
        local moving = false

        if love.keyboard.isDown("d") then self.vx = self.speed; self.flip_h = 1; moving = true end
        if love.keyboard.isDown("a") then self.vx = -self.speed; self.flip_h = -1; moving = true end
        if love.keyboard.isDown("w") then self.vy = -self.speed; moving = true end
        if love.keyboard.isDown("s") then self.vy = self.speed; moving = true end

        if self.vx ~= 0 and self.vy ~= 0 then
            local diagSpeed = self.speed / math.sqrt(2)
            self.vx = self.vx > 0 and diagSpeed or -diagSpeed
            self.vy = self.vy > 0 and diagSpeed or -diagSpeed
        end
        
        local dx = self.vx * dt
        local dy = self.vy * dt
        
        self.x, self.y = world:move(self, self.x + dx, self.y + dy, function(item, other)
            return "slide"
        end)

        if moving then
            self.animCorrendo:update(dt)
        else
            self.animParado:update(dt)
        end
    end

    function self:draw()
        if self.isDead then return end
        local currentAnim = (self.vx ~= 0 or self.vy ~= 0) and self.animCorrendo or self.animParado
        
        love.graphics.draw(
            currentAnim.image, currentAnim:getCurrentQuad(), self.x, self.y, 0, self.flip_h, 1, self.origemX, self.origemY
        )
        
        local selectedItem = Hotbar.api:getSelectedItem()
        if selectedItem and Tools.api.getDamage(selectedItem.type) then
            local toolImage = Tools.api.getImage(selectedItem.type)
            if toolImage then
                love.graphics.draw(toolImage, self.x + 8, self.y + 4, nil, nil, nil, 8, 4)
            end
        end
    end
    
    function self:keypressed(key)
        if key == "space" then print("O jogador apertou a barra de espaço!") end
    end
    
    return self
end

return Player
