player1 = {
    y = 0,
    x = 0,
    len = 10,
    thickness =3,
    speed = 75
}
player2 = {
    y = 0,
    x = 0,
    len = 10,
    thickness =3
}
ball = {
    x = 0,
    y = 0,
    xVel = 0,
    yVel = 0,
    size = 3,
}
screen = {
    x = 64,
    y = 48,
    scale=10
}
collborder = {
        left =  player2.thickness + 4,
        right = screen.x - player1.thickness - 3
    }
colors = {
    white =  {255,255,255},
    gray =   {200,200,200},
    darkGray={100,100,100},
    violet = {150,150,255}
}
canvas = love.graphics.newCanvas(screen.x,screen.y)
difficulty = 2
difficulties = {"easy", "normal", "hard"}
score = {
    player = 0,
    deaths = 0,
    cpu = 0,
    limits = {5,3,1},
    limit = nil
}
function resetball()
    ball.x = screen.x/2
    ball.y = screen.y/2
    ball.xVel = (math.random(-1,1) > 0) and 35 or -35
    ball.yVel = math.random(-15,15)
end
function initgame() --init/reset game state
    resetball()
    inmenu = true
    alive = true
    player1.x = collborder.right
    player1.y = screen.y/2
    player2.x = collborder.left-player2.thickness
    score.player = 0
    score.deaths = 0
    score.cpu = 0
end

function love.load()
    font = love.graphics.newFont("AerxFont.ttf", 16)
    sounds = {
        bounce = love.audio.newSource("bounce.wav")
    }
    kittyimg = love.graphics.newImage("kitty.png")
    initgame()
end

function love.keypressed(key, sc, r)
    local length = table.getn(difficulties)
    if not r and inmenu then
        if key == "up" then
            -- (test) ? cond1 : cond2
            difficulty = (difficulty+1 > length) and 1 or difficulty+1
        elseif key == "down" then
            difficulty = (difficulty-1 <= 0) and length or difficulty-1
        elseif key == "return" then 
            score.limit = score.limits[difficulty]--xxx
            inmenu = false
        end
    end
            
end

function love.update(dt)
    --misc input
    if love.keyboard.isDown('q') then
        love.event.push('quit')
    end
    if not alive then
        if love.keyboard.isDown('r') or love.keyboard.isDown('return') then
            initgame()
        end
        return
    end
    if inmenu then
        return
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
    --cpu paddle
    do
        local last = player2.y
        local jitter = math.random(-1,1)
        local cap = nil
        if difficulty == 1 then
            cap = 6
        elseif difficulty == 2 then
            cap = 10
        elseif difficulty == 3 then
            cap = 20
        end
        player2.y = ((ball.y+ball.size/2)-player2.len/2)
        local diff = player2.y - last
        if math.abs(diff) > cap*dt then
            if diff <= 0 then
                player2.y = last-cap*dt
            else
                player2.y = last+cap*dt
            end
        end
    end
    --ball logic
    ball.x = ball.x + ball.xVel * dt
    ball.y = ball.y + ball.yVel * dt
    --collision check
    function paddlecoll(player) 
        ball.xVel = -ball.xVel
        local rand =  math.random(-1, 1)
        local veer = (ball.y+ball.size/2) - (player.y+player.len/2)
        ball.yVel = veer*3+rand*2
        ball.xVel = ball.xVel + difficulty*2
        sounds.bounce:setPitch(1.5)
        sounds.bounce:play()
    end
    if ball.x + ball.size >= collborder.right then--right border
        if ball.y+ball.size >= player1.y and ball.y <= player1.y + player1.len and math.abs((ball.x + ball.size) - collborder.right) <2 then --hit paddle
            paddlecoll(player1)
            ball.x = collborder.right - ball.size-1 --anti stick
        else --missed
--             score.player = score.player -1
            score.cpu = score.cpu+1
            score.deaths = score.deaths+1
            resetball()
            if score.deaths > score.limit then
                print(score.deaths)
                alive = false
            end
        end
    end
    if ball.x <= collborder.left then--left border
        if ball.y+ball.size >= player2.y and ball.y <= player2.y + player2.len then --hit paddle
            ball.x = collborder.left
            paddlecoll(player2)
        else
            score.player = score.player + 1
--             score.cpu = score.cpu-1
            resetball()
        end
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
        love.graphics.setColor(colors.white)
        love.graphics.printf(string.format("Game Over\n%d:%d\nRestart..R\nQuit..Q", score.cpu, score.player), 0, 1, screen.x, 'center')
    elseif inmenu then
        love.graphics.setColor(colors.gray)
        love.graphics.printf("Pong", 0, 5, screen.x, 'center')
        love.graphics.setColor(colors.white)
        love.graphics.printf(string.format("Difficulty\n%s", difficulties[difficulty]), 0, 12, screen.x, 'center')
    else
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle('rough')
        --decorations
        love.graphics.setColor(255,255,255,150)
        love.graphics.draw(kittyimg, 15,10)
        love.graphics.setColor(colors.darkGray)
        love.graphics.printf(string.format("%i-%i", score.cpu, score.player), 0, 5, screen.x, 'center')
        love.graphics.printf(string.format("%d/%d", score.deaths, score.limit), 0, 36, screen.x, 'center')
        love.graphics.setColor(160,160,160,100)
        love.graphics.rectangle('fill', screen.x/2-1, 0, 1, screen.y)
        --love.graphics.rectangle('fill', collborder.right, 0, 5, love.graphics:getHeight())
        --draw ball
        love.graphics.setColor(colors.violet)
        love.graphics.rectangle('fill', ball.x, ball.y, ball.size, ball.size)
        --ball sparkles
        for i=1, 100 do
            local x = ball.x+ball.size/2
            local y = ball.y+ball.size/2
            love.graphics.setColor(math.random(200,255),math.random(200,255),math.random(200,255),math.random(25,100))
            local dist = 4*i/100
            love.graphics.rectangle('fill',x+math.random(-dist,dist), y+math.random(-dist,dist),1,1)
        end
        --draw paddles
        love.graphics.setColor(colors.white)
        love.graphics.rectangle('line', player1.x, player1.y, player1.thickness, player1.len)    speed = 
        love.graphics.setColor(colors.gray)
        love.graphics.rectangle('line', player2.x, player2.y, player2.thickness, player2.len)
    end
    
    --noise effect
    for y=0,screen.y do
        for x=0,screen.x do
            local color = math.random(0,255)
            love.graphics.setColor(color,color,color,25)
            love.graphics.rectangle('fill',x,y,1,1)
        end
    end
    love.graphics.setColor(255,255,255,255)
    
    love.graphics.setCanvas()
--     love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(canvas, 0,0,0, screen.scale, screen.scale)
end
