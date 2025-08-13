-- mods/inimigos/init.lua

local Inimigos = {}
local world = nil
local player = nil
local Health = nil
local enemyImage = nil
local allEnemies = {} -- AQUI: Uma tabela para rastrear todos os inimigos

Inimigos.api = {}

function Inimigos.init(bumpWorld, playerObj, healthModule)
    world = bumpWorld
    player = playerObj
    Health = healthModule
    print("Módulo de inimigos inicializado!")
    enemyImage = love.graphics.newImage("mods/inimigos/textures/slime.png")
end

function Inimigos.api:getEnemies()
    return allEnemies
end

function Inimigos.api:remove(enemy)
    world:remove(enemy)
    for i, e in ipairs(allEnemies) do
        if e == enemy then
            table.remove(allEnemies, i)
            break
        end
    end
end

function Inimigos.new(x, y)
    local self = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        largura = 16,
        altura = 16,
        speed = 50,
        classe = "inimigo",
        health = 20, -- AQUI: Adicionamos vida ao inimigo
        damage = 5,
    }

    world:add(self, self.x, self.y, self.largura, self.altura)
    table.insert(allEnemies, self) -- AQUI: Adiciona o novo inimigo à lista

    function self:update(dt)
        local dx = player.x - self.x
        local dy = player.y - self.y
        local distance = math.sqrt(dx^2 + dy^2)

        if distance > 10 then
            local dirX = dx / distance
            local dirY = dy / distance
            self.vx = dirX * self.speed
            self.vy = dirY * self.speed
        else
            self.vx = 0
            self.vy = 0
        end

        self.x, self.y = world:move(self, self.x + self.vx * dt, self.y + self.vy * dt, function(item, other)
            if other == player then
                Health.api:takeDamage(self.damage)
                return "cross"
            end
            return "slide"
        end)
    end

    function self:draw()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(enemyImage, self.x, self.y)

        -- AQUI: Desenha uma pequena barra de vida acima do inimigo
        local healthBarWidth = 20
        local healthBarHeight = 3
        love.graphics.setColor(1, 0, 0, 1) -- Vermelho
        love.graphics.rectangle("fill", self.x - 2, self.y - 5, healthBarWidth, healthBarHeight)
        local greenBarWidth = (self.health / 20) * healthBarWidth
        love.graphics.setColor(0, 1, 0, 1) -- Verde
        love.graphics.rectangle("fill", self.x - 2, self.y - 5, greenBarWidth, healthBarHeight)
    end

    function self:takeDamage(amount)
        self.health = self.health - amount
        print("Inimigo tomou " .. amount .. " de dano. Vida restante: " .. self.health)
        if self.health <= 0 then
            Inimigos.api:remove(self)
        end
    end

    return self
end

return Inimigos
