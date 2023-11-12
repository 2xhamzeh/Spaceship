
-- *
-- load function ----------------------------------------------------------------------------------------
-- *

function love.load()

    require 'wordList'

    button = require 'Button'

    love.window.setMode(1280, 720)

    gameStateAndButtons()

    setupSprites()

    spawnPlayer()

    balloons = {}

    bullets = {}

    -- score and font and balloon spawn timer
    score = 100

    font = love.graphics.newFont('ZenDots-Regular.ttf', 32)
    love.graphics.setFont(font)

    BalloonSpawnMaxTime = 2
    BalloonSpawnTimer = BalloonSpawnMaxTime

    gameOverTimer = 0
 
end

-- *
-- update function ----------------------------------------------------------------------------------------
-- *

function love.update(dt)

    
    objectMovement(dt)

    trashCollection()

    -- this function also handels balloon animation on collision
    -- also handels mouse position for buttons
    detectCollision(dt)

    -- ship animation 
    shipAnimation(dt)

    balloonAutomaticSpawn(dt)


    -- Game Over state
    if score <= 0 then
        changeGameState("gameOver")
    end
    if game.state["gameOver"] then
        gameOverTimer = gameOverTimer + dt
    end
    if game.state["gameOver"] and gameOverTimer > 2 then
        changeGameState("menu")
        gameOverTimer = 0
        score = 100
    end

end

-- *
-- draw function ----------------------------------------------------------------------------------------
-- *

function love.draw()

    --- Drawing Buttons
    if game.state["menu"] then
        love.graphics.draw(sprites.menuBackground)
        buttons.menu_state.play_game:draw(love.graphics.getWidth() / 2 - 125, love.graphics.getHeight() / 2 - 60, 20, 12, 0.91, 0.50, 0.30)
        buttons.menu_state.exit_game:draw(love.graphics.getWidth() / 2 - 125, love.graphics.getHeight() / 2 - 60 + 80, 24, 12, 0.91, 0.50, 0.30)
    end

    if game.state["gameOver"] then
        love.graphics.draw(sprites.gameOverBackground)
    end

    

    --- wenn der Game-Status "running" ist / Wenn das Spiel beginnt
    if game.state["running"] then

        love.graphics.draw(sprites.background)

        -- menu button
        buttons.running_state.menu:draw(20, 20, 20, 12, 0.91, 0.50, 0.30)

        
        -- Drawing bullets
        love.graphics.setColor(255/255, 140/255, 61/255)
        for i,b in ipairs(bullets) do
            love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
        end
        love.graphics.setColor(1,1,1)

        -- Drawing player
        love.graphics.draw(sprites.ship, sprites.shipAnimation[sprites.shipFrame], player.x, player.y)


        -- Drawing balloons
        for k,o in ipairs(balloons) do
            for i, b in ipairs(o) do
                
                if b.sprite == "pic" then
                    love.graphics.draw(sprites.balloonPic, b.x, b.y)
                else
                    love.graphics.draw(sprites.balloon, sprites.balloonAnimation[sprites.balloonFrame], b.x, b.y)
                end
                love.graphics.print(b.text, b.x + b.width, b.y + b.height / 2)
            end 
        end

        -- prints the score
        -- love.graphics.setColor(0/255, 138/255, 169/255)
        -- love.graphics.rectangle('fill', love.graphics.getWidth() - 340, 20, 320, 60)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Score: "..score, love.graphics.getWidth() - 330, 32)
    end


    

end

----------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------

-- Check for input
function love.keypressed(key)

    -- spawn balloons when a is pressed
    -- if key == 'a' then
    --     spawnBalloons()
    -- end

    -- quit
    if key == 'escape' then
        love.event.quit()
    end

    -- spawn bullets with space
    if key == 'space' then
        spawnBullets()
    end

end

----------------------------------------------------------------------------------------

-- basically the player object
function spawnPlayer()
    player = {}
    player.x = 150
    player.y = love.graphics.getHeight() / 2 - sprites.shipQuadWidth / 2
    player.width = sprites.shipQuadWidth
    player.height = sprites.shipHeight
    player.speed = 1000
end

----------------------------------------------------------------------------------------

-- creates a balloon pair when called
function spawnBalloons()
    local balloonSpeed = 300

    -- first balloon
    local balloon = {}
    balloon.width = sprites.balloonQuadWidth
    balloon.height = sprites.balloonHeight
    balloon.x = love.graphics.getWidth() + sprites.balloonQuadWidth
    balloon.y = love.graphics.getHeight() / 4 - balloon.height / 2 + 50
    balloon.speed = balloonSpeed
    balloon.dead = false
    balloon.correct = false
    balloon.text = ''
    balloon.sprite = "pic"
    
    -- second balloon
    local balloon2 = {}
    balloon2.width = sprites.balloonQuadWidth
    balloon2.height = sprites.balloonHeight
    balloon2.x = love.graphics.getWidth() + sprites.balloonQuadWidth
    balloon2.y = love.graphics.getHeight() / 4 * 3 - balloon2.height / 2 + 50
    balloon2.speed = balloonSpeed
    balloon2.dead = false
    balloon2.correct = false
    balloon2.text = ''
    balloon2.sprite = "pic"
    
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

----------------------------------------------------------------------------------------

-- creates bullets when called
function spawnBullets()
    local bullet = {}
    bullet.x = player.x + player.width/2
    bullet.y = player.y + player.height/2 + 20
    bullet.width = 30 -- should be bulletSpriteWidth
    bullet.height = 3 -- should be bulletSpriteHeight
    bullet.speed = 3000
    bullet.dead = false
    table.insert(bullets, bullet)
end

----------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------

-- removes objects outside of screen
function trashCollection()

    -- removing bullets when they exit screen, right side of screen in this case
    for i = #bullets , 1, -1 do
        local b = bullets[i]
        if b.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end
    end

    -- removing balloons when they collide with ship
    for k,o in ipairs(balloons) do
        for i, b in ipairs(o) do
            if b.x < player.x + player.width/2 then
                b.sprite = "dead"
                b.dead = true
            end
        end
    end

end

----------------------------------------------------------------------------------------

-- a function that detects collision between balloons and bullets and gives them behaivor when it happens
function detectCollision(dt)

    -- checks mouse position for buttons
    mouse.x, mouse.y = love.mouse.getPosition()

    -- detect collision
    for k,o in ipairs(balloons) do
        for i, balloon in ipairs(o) do
            for j, bullet in ipairs(bullets) do
                if  (bullet.x + bullet.width >= balloon.x)
                and (balloon.y < bullet.y + bullet.height/2)
                and (bullet.y + bullet.height/2 < balloon.y + balloon.height)  then
                    -- when a bullet and a balloon collide their field dead is set to true
                    balloon.sprite = "dead"
                    bullet.dead = true
                    balloon.dead = true
                    if balloon.correct == true then
                        score = score + 100
                    else
                        score = score - 100
                    end
                end
            end
        end
    end

    -- remove dead bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            -- this is what happens to bullet when it collids
            table.remove(bullets, i)
        end
    end

    -- remove dead balloons
    for k = #balloons, 1, -1 do
        local o = balloons[k]

        for i = #o, 1, -1 do
            local b = o[i]

            if b.dead == true then

                -- this is what happens to balloon when it collids

                sprites.balloonTimer = sprites.balloonTimer + dt
                if sprites.balloonTimer >= 0.2 then
                    sprites.balloonTimer = 0.1
                    sprites.balloonFrame = sprites.balloonFrame + 1
                    if sprites.balloonFrame > sprites.balloonMaxFrames then
                        sprites.balloonFrame = 1
                        o.removed = true
                    end
                end

            end

        end

        if o.removed == true then
            table.remove(balloons, k)
        end

    end
end

----------------------------------------------------------------------------------------

function balloonAutomaticSpawn(dt)
    if game.state['running'] then
        BalloonSpawnTimer = BalloonSpawnTimer - dt
        if BalloonSpawnTimer <= 0 then
            spawnBalloons()
            BalloonSpawnTimer = BalloonSpawnMaxTime
        end
    end
    if game.state["gameOver"] or game.state["menu"] then
        for i = #balloons, 1, -1 do
            table.remove(balloons[i])
        end
    end
end

----------------------------------------------------------------------------------------

function setupSprites()


    sprites = {}
    sprites.balloonPic = love.graphics.newImage("sprites/balloon.png")
    sprites.balloon = love.graphics.newImage("sprites/balloonSmall.png")
    sprites.balloonHeight = 216
    sprites.balloonWidth = 1080
    sprites.balloonQuadWidth = sprites.balloonWidth / 6
    sprites.balloonMaxFrames = 6
    sprites.balloonAnimation = {}
    sprites.balloonFrame = 1
    sprites.balloonTimer = 0.1
    
    for i = 1, sprites.balloonMaxFrames do
        sprites.balloonAnimation[i] = love.graphics.newQuad(sprites.balloonQuadWidth * (i - 1), 0, sprites.balloonQuadWidth, sprites.balloonHeight, sprites.balloonWidth, sprites.balloonHeight)
    end
    

    sprites.ship = love.graphics.newImage("sprites/shipSmall.png")
    sprites.shipHeight = 190
    sprites.shipWidth = 900
    sprites.shipQuadWidth = sprites.shipWidth/3
    sprites.shipMaxFrames = 3
    sprites.shipAnimation = {}
    sprites.shipFrame = 1
    sprites.shipTimer = 0.1

    for i = 1, sprites.shipMaxFrames do
        sprites.shipAnimation[i] = love.graphics.newQuad(sprites.shipQuadWidth * (i - 1), 0, sprites.shipQuadWidth, sprites.shipHeight, sprites.shipWidth, sprites.shipHeight)
    end

    sprites.background = love.graphics.newImage("sprites/background.png")
    sprites.gameOverBackground = love.graphics.newImage("sprites/gameOverScreen.png")
    sprites.menuBackground = love.graphics.newImage("sprites/menuBackground.png")

end

----------------------------------------------------------------------------------------

function gameStateAndButtons()
    --- Game states:
    game = {
        state = {
            menu = true,
            running = false,
            gameOver = false
        } 
    } 
    --- Change Game state
    function changeGameState(state) 
        game.state["menu"] = state == "menu"
        game.state["running"] = state == "running"
        game.state["gameOver"] = state == "gameOver"
    end
    --- Buttons:
    buttons = {
        menu_state = {},
        running_state = {}
    }
    --- Create Buttons
    buttons.menu_state.play_game = button("Play Game", changeGameState, "running", 250, 60)
    buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 250, 60)

    buttons.running_state.menu = button("Menu", changeGameState, "menu", 150, 60)
    --- Mouse detection
    mouse = {
        x = 0,
        y = 1
    }
end

----------------------------------------------------------------------------------------

function shipAnimation(dt)
    sprites.shipTimer = sprites.shipTimer + dt
    if sprites.shipTimer >= 0.5 then
        sprites.shipTimer = 0.1
        sprites.shipFrame = sprites.shipFrame + 1
        if sprites.shipFrame > sprites.shipMaxFrames then
            sprites.shipFrame = 1
        end
    end
end

----------------------------------------------------------------------------------------



