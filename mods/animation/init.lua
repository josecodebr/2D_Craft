-- mods/animation/init.lua
local Animation = {}

-- Construtor para criar uma nova animação
function Animation.new(image, frameWidth, frameHeight, duration, numFrames)
    local anim = {
        image = image,
        frameWidth = frameWidth,
        frameHeight = frameHeight,
        duration = duration,
        numFrames = numFrames,
        timer = 0,
        currentFrame = 1,
        quads = {}
    }

    -- Cria todos os 'quads' de uma vez
    local imageWidth, imageHeight = image:getDimensions()
    for i = 0, numFrames - 1 do
        anim.quads[i + 1] = love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, imageWidth, imageHeight)
    end

    function anim:update(dt)
        anim.timer = anim.timer + dt
        while anim.timer >= anim.duration do
            anim.timer = anim.timer - anim.duration
            anim.currentFrame = anim.currentFrame + 1
            if anim.currentFrame > anim.numFrames then
                anim.currentFrame = 1
            end
        end
    end

    function anim:getCurrentQuad()
        return anim.quads[anim.currentFrame]
    end

    return anim
end

return Animation
