push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    gamemode = ''

    servingPlayer = 1

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'menu_screen'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        if gameMode == 'pvp' or gameMode == 'pvc' then
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'

                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if gameMode == 'pvp' then

        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0 
        end

    elseif gameMode == 'pvc' then

        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end 

        if (player2.y + player2.height / 2) > ball.y + ball.height / 2 then
            player2.dy = -PADDLE_SPEED
        elseif (player2.y + player2.height / 2) < ball.y + ball.height / 2 then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end

    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        if gameMode == 'pvp' or gameMode == 'pvc' then 
            if gameState == 'start' then
                gameState = 'serve'
            elseif gameState == 'serve' then
                gameState = 'play'
            elseif gameState == 'done' then
                gameState = 'serve'
    
                ball:reset()
    
                player1Score = 0
                player2Score = 0
    
                if winningPlayer == 1 then
                    servingPlayer = 2
                else
                    servingPlayer = 1
                end
            end
        end
    end

    if gameState == 'menu_screen' then
        if key == '1' then
            gameMode = 'pvp'
        elseif key == '2' then
            gameMode = 'pvc'
        end
        gameState = 'start'
    end

end

function love.draw()

    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)

    displayScore()

    if gameState == 'menu_screen' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Chose a gamemode', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Player vs Player \n 2. Player vs Computer', 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Space to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        if gameMode == 'pvp' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Space to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'pvc' then
            if servingPlayer == 1 then
                love.graphics.setFont(smallFont)
                love.graphics.printf("Player's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Space to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
            else
                love.graphics.setFont(smallFont)
                love.graphics.printf("Computer's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Space to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
            end
        end
    elseif gameState == 'play' then

    elseif gameState == 'done' then
        if gameMode == 'pvp' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Space to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'pvc' then
            if winningPlayer == 1 then
                love.graphics.setFont(largeFont)
                love.graphics.printf("Player wins!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.setFont(smallFont)
                love.graphics.printf('Press Space to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
            else
                love.graphics.setFont(largeFont)
                love.graphics.printf("Computer wins!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.setFont(smallFont)
                love.graphics.printf('Press Space to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
            end   
        end
    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
