

function love.load()

    require 'wordList'

    button = require 'Button'

    anim8 = require 'anim8'

    love.window.setMode(1280, 720)

    spawnPlayer()

    balloons = {}

    bullets = {}

    score = 1000


    --- Game states:
    game = {
        state = {
            menu = true,
            running = false
        } 
    }
    --- Buttons:
    buttons = {
        menu_state = {},
        running_state = {}
    }
    --- Change Game state
    local function changeGameState(state) 
        game.state["menu"] = state == "menu"
        game.state["running"] = state == "running"
    end
    --- Create Buttons
    buttons.menu_state.play_game = button("Play Game", changeGameState, "running", 250, 65)
    buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 250, 65)

    buttons.running_state.menu = button("Menu", changeGameState, "menu", 120, 65)
    --- Mouse detection
    mouse = {
        x = 0,
        y = 1
    }
    ----

    font = love.graphics.newFont('Marhey-VariableFont_wght.ttf', 30)
    love.graphics.setFont(font)

    



    -- Sprites --
    
    -- sprites = {}
    -- sprites.balloon = love.graphics.newImage("sprites/baloonSmall.png")
    -- sprites.balloonHeight = 100
    -- sprites.balloonWidth = 506
    -- sprites.balloonQuadWidth = 506/6
    -- sprites.balloonMaxFrames = 6
    -- sprites.balloonAnimation = {}
    -- sprites.balloonFrame = 1
    -- sprites.balloonTimer = 0.1
    
    -- for i = 1, sprites.balloonMaxFrames do
    --     sprites.balloonAnimation[i] = love.graphics.newQuad(sprites.balloonQuadWidth * (i - 1), 0, sprites.balloonQuadWidth, sprites.balloonHeight, sprites.balloonWidth, sprites.balloonHeight)
    -- end
    


    -- sprites.ship = love.graphics.newImage("sprites/shipSmall.png")
    -- sprites.shipHeight = 100
    -- sprites.shipWidth = 473
    -- sprites.shipQuadWidth = 473/3
    -- sprites.shipMaxFrames = 3
    -- sprites.shipAnimation = {}
    -- sprites.shipFrame = 1
    -- sprites.shipTimer = 0.1

    -- for i = 1, sprites.shipMaxFrames do
    --     sprites.shipAnimation[i] = love.graphics.newQuad(sprites.shipQuadWidth * (i - 1), 0, sprites.shipQuadWidth, sprites.shipHeight, sprites.shipWidth, sprites.shipHeight)
    -- end


    -- Sprites2.0 --

    sprites = {}
    sprites.ship = love.graphics.newImage("sprites/shipSmall.png")
    sprites.shipGrid = anim8.newGrid(157,100,sprites.ship:getWidth(),sprites.ship:getHeight())
    sprites.shipAnimation = anim8.newAnimation(sprites.shipGrid('1-3', 1), 0.2)

    sprites.balloonPic = love.graphics.newImage("sprites/balloon.png")
    sprites.balloon = love.graphics.newImage("sprites/baloonSmall.png")
    sprites.balloonGrid = anim8.newGrid(84,100,sprites.balloon:getWidth(), sprites.balloon:getHeight())
    sprites.balloonAnimation = anim8.newAnimation(sprites.balloonGrid('1-6', 1), 0.25)

    -- BalloonAutoSpawn
    BalloonSpawnMaxTime = 2
    BalloonSpawnTimer = BalloonSpawnMaxTime

end

function love.update(dt)

    mouse.x, mouse.y = love.mouse.getPosition()
    
    objectMovement(dt)

    trashCollection()

    detectCollision(dt)

    -- ship animation 
    -- sprites.shipTimer = sprites.shipTimer + dt
    -- if sprites.shipTimer >= 0.5 then
    --     sprites.shipTimer = 0.1
    --     sprites.shipFrame = sprites.shipFrame + 1
    --     if sprites.shipFrame > sprites.shipMaxFrames then
    --         sprites.shipFrame = 1
    --     end
    -- end

    sprites.shipAnimation:update(dt)
    sprites.balloonAnimation:update(dt)
    ---------

    -- 

    balloonAutomaticSpawn(dt)

end

function love.draw()
    --- wenn der Game-Status "running" ist / Wenn das Spiel beginnt
    if game.state["running"] then


        -- Drawing bullets
        for i,b in ipairs(bullets) do
            love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
        end



        -- Drawing player
        -- love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)
        sprites.shipAnimation:draw(sprites.ship, player.x, player.y)
        -- love.graphics.draw(sprites.ship, sprites.shipAnimation[sprites.shipFrame], player.x, player.y)





        -- Drawing balloons
        for k,o in ipairs(balloons) do
            for i, b in ipairs(o) do
                -- love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
                if b.sprite == "pic" then
                    love.graphics.draw(sprites.balloonPic, b.x, b.y)
                else
                    sprites.balloonAnimation:draw(sprites.balloon, b.x, b.y)
                end
                
                
                -- love.graphics.draw(sprites.balloon, sprites.balloonAnimation[sprites.balloonFrame], b.x, b.y)
                love.graphics.print(b.text, b.x + b.width, b.y + b.height / 2)
            end 
        end



        -- prints the score
        love.graphics.print(score, love.graphics.getWidth() - 200, 100)

    end

    --- Drawing Buttons
    if game.state["menu"] then
        buttons.menu_state.play_game:draw(10, 20, 30, 8)
        buttons.menu_state.exit_game:draw(10, 90, 30, 8)
    elseif game.state["running"] then
        buttons.running_state.menu:draw(10, 20, 15, 8)
    end 
end



--- detecting mousepresses on buttons
function love.mousepressed(x, y, button, isTouch, presses)
    if not game.state["running"] then
        if button == 1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(mouse.x, mouse.y)
                end
            end
        end
    else
        for index in pairs(buttons.running_state) do
            buttons.running_state[index]:checkPressed(mouse.x, mouse.y)
        end
    end
end

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
    balloon.sprite = "pic"
    balloon.deathTimer = 0
    
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
    balloon2.sprite = "pic"
    balloon2.deathTimer = 0
    
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
function detectCollision(dt)

    -- detect collision
    for k,o in ipairs(balloons) do
        for i, balloon in ipairs(o) do
            for j, bullet in ipairs(bullets) do
                if  (bullet.x + bullet.width >= balloon.x)
                and (balloon.y < bullet.y + bullet.height/2)
                and (bullet.y + bullet.height/2 < balloon.y + balloon.height)  then

                    -- start balloon death animation
                    balloon.sprite = "dead"


                    -- when a bullet and a balloon collide their field dead is set to true
                    bullet.dead = true
                    balloon.dead = true


                end
            end
        end
    end


    for k, o in ipairs(balloons) do 
        for i, b in ipairs(o) do
            if b.dead then
                b.deathTimer = b.deathTimer + dt
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
                if b.deathTimer > 1 then
                    o.removed = true
                end
                -- this is what happens to balloon when it collids
                -- sprites.balloonTimer = sprites.balloonTimer + dt
                -- if sprites.balloonTimer >= 0.2 then
                --     sprites.balloonTimer = 0.1
                --     sprites.balloonFrame = sprites.balloonFrame + 1
                --     if sprites.balloonFrame > sprites.balloonMaxFrames then
                --         sprites.balloonFrame = 1
                --     end
                -- end
                -- if sprites.balloonFrame == sprites.balloonMaxFrames then
                --     o.removed = true
                --     sprites.balloonFrame = 1
                -- end
                if o.removed then
                    if b.correct == true then
                        score = score + 100
                    else
                        score = score - 100
                    end
                end
            end
        end

        if o.removed == true then
            table.remove(balloons, k)
        end

    end
end

function balloonAutomaticSpawn(dt)
    if game.state['running'] then
        BalloonSpawnTimer = BalloonSpawnTimer - dt
        if BalloonSpawnTimer <= 0 then
            spawnBalloons()
            BalloonSpawnTimer = BalloonSpawnMaxTime
        end
    end
end