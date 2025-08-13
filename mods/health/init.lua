-- mods/health/init.lua

local Health = {}

local playerHealth = 100
local maxHealth = 100
local myPlayerInstance = nil -- AQUI: A variável agora se chama myPlayerInstance

Health.api = {}

-- AQUI: O módulo agora recebe a instância do jogador
function Health.init(playerInstance)
    myPlayerInstance = playerInstance
    print("Módulo de vida inicializado!")
end

function Health.api:takeDamage(amount)
    playerHealth = playerHealth - amount
    if playerHealth <= 0 then
        playerHealth = 0
        -- AQUI: Chama o método die() do myPlayerInstance
        myPlayerInstance:die()
    end
    print("O jogador tomou dano! Vida restante: " .. playerHealth)
end

function Health.api:heal(amount)
    playerHealth = math.min(playerHealth + amount, maxHealth)
    print("O jogador se curou! Vida restante: " .. playerHealth)
end

function Health.api:resetHealth()
    playerHealth = maxHealth
    print("A vida do jogador foi restaurada.")
end

function Health.api.isDead()
    return playerHealth <= 0
end

function Health.api:draw()
    local x = 10
    local y = 10
    local width = 100
    local height = 10
    
    love.graphics.setColor(0.5, 0, 0, 1)
    love.graphics.rectangle("fill", x, y, width, height)
    
    local currentWidth = (playerHealth / maxHealth) * width
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", x, y, currentWidth, height)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
end

return Health
