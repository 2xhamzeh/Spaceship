
--[[
    *
    *
    * load function
    *
    *
]]

function love.load()

    require 'wordList'

    love.window.setMode(1280, 720)

    spawnPlayer()

    balloons = {}

    bullets = {}

    score = 1000

    
    font = love.graphics.newFont('Marhey-VariableFont_wght.ttf', 30)
    love.graphics.setFont(font)

    
end

--[[
    *
    *
    * update function
    *
    *
]]

function love.update(dt)
    
    objectMovement(dt)

    trashCollection()

    detectCollision()
    
end

--[[
    *
    *
    * draw function
    *
    *
]]

function love.draw()

    love.graphics.setColor(255,0,0) -- extra

    -- Drawing bullets
    for i,b in ipairs(bullets) do
        love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
    end

    love.graphics.setColor(0,255,0) -- extra

    -- Drawing player
    love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)

    love.graphics.setColor(0,0,255) -- extra

    -- Drawing balloons
    for k,o in ipairs(balloons) do
        for i, b in ipairs(o) do
            love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
            love.graphics.print(b.text, b.x + b.width, b.y + b.height / 2)
        end 
    end

    love.graphics.setColor(255,255,255)

    -- prints the score
    love.graphics.print(score, love.graphics.getWidth() - 200, 100)
    
end



--[[
    *
    *
    * other functions
    *
    *
]]




-- Check for input
function love.keypressed(key)

    -- spawn balloons when a is pressed
    if key == 'a' then
        spawnBalloons()
    end

    -- quit
    if key == 'escape' then
        love.event.quit()
    end

    -- spawn bullets with space
    if key == 'space' then
        spawnBullets()
    end

end





-- basically the player object
function spawnPlayer()
    player = {}
    player.x = 150
    player.y = love.graphics.getHeight() / 2 -- still need to include - playerSpriteHeight / 2
    player.width = 100 -- should be playerSpriteWidth
    player.height = 100 -- should be playerSpriteHeight
    player.speed = 1000
end





-- creates a balloon pair when called
function spawnBalloons()
    local balloonSpeed = 200

    -- first balloon
    local balloon = {}
    balloon.x = love.graphics.getWidth() - 100 -- 100 should be balloon sprite width
    balloon.y = love.graphics.getHeight() /4
    balloon.width = 100 -- should be balloonSpriteWidth
    balloon.height = 100 -- should be balloonSpriteHeight
    balloon.speed = balloonSpeed
    balloon.dead = false
    balloon.correct = false
    balloon.text = ''
    balloon.neighbor = 1
    
    -- second balloon
    local balloon2 = {}
    balloon2.x = love.graphics.getWidth() - 100 -- 100 should be balloon sprite width
    balloon2.y = love.graphics.getHeight() / 4 * 3
    balloon2.width = 100 -- should be balloonSpriteWidth
    balloon2.height = 100 -- should be balloonSpriteHeight
    balloon2.speed = balloonSpeed
    balloon2.dead = false
    balloon2.correct = false
    balloon2.text = ''
    balloon2.neighbor = -1
    
    -- gets wordPair from wordList and assigns them to the balloons randomly
    local wordPair = getPair()
    local randNum = math.random(2)
    if randNum == 1 then
        balloon.text = wordPair[1]
        balloon2.text = wordPair[2]
        balloon.correct = true
        balloon2.correct = false
    else
        balloon.text = wordPair[2]
        balloon2.text = wordPair[1]
        balloon.correct = false
        balloon2.correct = true
    end

    -- creates the balloon pair
    local balloonPair = {balloon, balloon2}
    balloonPair.removed = false
    table.insert(balloons, balloonPair)
end





-- creates bullets when called
function spawnBullets()
    local bullet = {}
    bullet.x = player.x + player.width/2
    bullet.y = player.y + player.height/2
    bullet.width = 10 -- should be bulletSpriteWidth
    bullet.height = 10 -- should be bulletSpriteHeight
    bullet.speed = 3000
    bullet.dead = false
    table.insert(bullets, bullet)
end






-- function that handels movement of every object in the game
function objectMovement(dt)

    -- Player movement
    if love.keyboard.isDown('up') then
        player.y = math.max(0, player.y - player.speed * dt)
    end
    if love.keyboard.isDown('down') then
        player.y = math.min(player.y + player.speed * dt, love.graphics.getHeight() - player.height)
    end


    -- Balloons movement
    for k,o in ipairs(balloons) do
        for i, b in ipairs(o) do
            b.x = b.x - b.speed * dt
        end
    end


    -- Bullets movement
    for i,b in ipairs(bullets) do
        b.x = b.x + b.speed * dt
    end

end






-- removes objects outside of screen
function trashCollection()

    -- removing bullets when they exit screen, right side of screen in this case
    for i = #bullets , 1, -1 do
        local b = bullets[i]
        if b.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end
    end

end






-- a function that detects collision between balloons and bullets and gives them behaivor when it happens
function detectCollision()

    -- detect collision
    for k,o in ipairs(balloons) do
        for i, balloon in ipairs(o) do
            for j, bullet in ipairs(bullets) do
                if  (bullet.x + bullet.width >= balloon.x)
                and (balloon.y < bullet.y + bullet.height/2)
                and (bullet.y + bullet.height/2 < balloon.y + balloon.height)  then
                    -- when a bullet and a balloon collide their field dead is set to true
                    bullet.dead = true
                    balloon.dead = true
                end
            end
        end
    end

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            -- this is what happens to bullet when it collids
            table.remove(bullets, i)
        end
    end

    for k = #balloons, 1, -1 do
        local o = balloons[k]

        for i = #o, 1, -1 do
            local b = o[i]
            if b.dead == true then
                -- this is what happens to balloon when it collids
                o.removed = true
                if b.correct == true then
                    score = score + 100
                else
                    score = score - 100
                end
            end
        end

        if o.removed == true then
            table.remove(balloons, k)
        end

    end
end











