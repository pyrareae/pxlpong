player1 = {
    y = 0,
    x = 0,
    len = 10,
    thickness =3,
    speed = 100
}
ball = {
    x = 0,
    y = 0,
    xVel = 0,
    yVel = 0,
    size = 2,
}
screen = {
    x = 64,
    y = 48,
    scale=10
}
collborder = {
        left = 0,
        right = screen.x - player1.thickness - 3
    }
canvas = love.graphics.newCanvas(screen.x,screen.y)
function initgame() --init/reset game state
    alive = true
    ball.x = screen.x/2
    ball.y = screen.y/2
    ball.xVel = 40
    ball.yVel = 0.2
    player1.x = collborder.right
    player1.y = screen.y/2
end

function love.load()
    font = love.graphics.newFont("pixelart.ttf", 8)
    sounds = {
        bounce = love.audio.newSource("bounce.wav")
    }
    initgame()
end

function love.update(dt)
    --misc input
    if love.keyboard.isDown('q') then
        love.event.push('quit')
    end
    if not alive then
        if love.keyboard.isDown('r') then
            initgame()
        end
        return
    end
    if inmenu then
        
    end
    --paddle logic
    if love.keyboard.isDown('up') then
        player1.y = player1.y - player1.speed * dt
        if player1.y < 0 then
            player1.y = 0
        end
    elseif love.keyboard.isDown('down') then 
        player1.y = player1.y + player1.speed * dt
        if player1.y > screen.y - player1.len then
            player1.y = screen.y - player1.len
        end
    end
    --ball logic
    ball.x = ball.x + ball.xVel * dt
    ball.y = ball.y + ball.yVel * dt
    --collision check
    if ball.x + ball.size >= collborder.right then--right border
        if ball.y+ball.size >= player1.y and ball.y <= player1.y + player1.len then --hit paddle
            ball.xVel = -ball.xVel
            local rand =  math.random(-1, 1)
            local veer = (ball.y+ball.size/2) - (player1.y+player1.len/2)
            ball.yVel = veer*3+rand*2
            ball.xVel = ball.xVel + 2
            ball.x = collborder.right - ball.size
            sounds.bounce:setPitch(1.5)
            sounds.bounce:play()
        else -- died!
            alive = false
        end
    end
    if ball.x < collborder.left then--left border
        ball.xVel = -ball.xVel
        ball.x = collborder.left
        sounds.bounce:setPitch(1)
        sounds.bounce:play()
    end
    if ball.y < 0 or ball.y+ball.size > screen.y then--top/bottom walls
        ball.yVel = -ball.yVel
        sounds.bounce:setPitch(1)
        sounds.bounce:play()
    end
end

function love.draw()
    canvas:setFilter('nearest', 'nearest', 0)
    love.graphics.setCanvas(canvas)
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
    love.graphics.clear()
    love.graphics.setFont(font)
    
    if not alive then
        love.graphics.setColor(255,255,255)
        love.graphics.printf("Game Over\n\nRestart..R\n\nQuit..Q", 0, 5, screen.x, 'center')
    elseif inmenu then
        
    else
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle('rough')
        --decorations
        love.graphics.setColor(200,200,200)
        love.graphics.rectangle('fill', screen.x/2, 0, 1, screen.y)
        --love.graphics.rectangle('fill', collborder.right, 0, 5, love.graphics:getHeight())
        --draw paddes
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle('line', player1.x, player1.y, player1.thickness, player1.len)
        --draw ball
        love.graphics.setColor(150,150,255)
        love.graphics.rectangle('fill', ball.x, ball.y, ball.size, ball.size)
    end
    
    love.graphics.setCanvas()
--     love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255,255,255)
    love.graphics.draw(canvas, 0,0,0, screen.scale, screen.scale)
end
