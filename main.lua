function love.load()
	hp = 200
	bolt_tex = love.graphics.newImage("res/bolt.png")
	ship_tex = love.graphics.newImage("res/ship.png")
	x_pos = 1024/2
	y_pos = 576/2
	rot = 0
	r = rot * math.pi / 180
	x_sp = 0
	y_sp = 0
	bolt_cd = 0
	math.randomseed(os.time())
	objects = {}
end

function love.draw()
	quad = love.graphics.rectangle("fill", 5, 5, hp*2, 20)
	for i = 1, #objects do
		if objects[i] ~= nil then 
			if objects[i][1] == 1 then
				tex = bolt_tex
			end
			love.graphics.draw(tex, objects[i][2], objects[i][3])
		end
	end
	ship = love.graphics.draw(ship_tex, x_pos, y_pos, r, 1, 1, 16, 16)
end

function love.update(dt)
	if bolt_cd < 1 then
		table.insert(objects, {1, math.random(0, 1024-16), math.random(25, 576-16)})
		bolt_cd = 5
		print(bolt_cd)
	else
		bolt_cd = bolt_cd - 3*dt
		print(bolt_cd)
	end	
	if hp > 0 then
		hp = hp-5*dt
	end
	x_pos = x_pos + x_sp*dt
	y_pos = y_pos + y_sp*dt
	
	if love.keyboard.isDown("right") then
		x_sp = x_sp + 1
	elseif love.keyboard.isDown("left") then
		x_sp = x_sp - 1
	elseif love.keyboard.isDown("up") then
		y_sp = y_sp - 1
	elseif love.keyboard.isDown("down") then
		y_sp = y_sp + 1
	end
	
	for i = 1, #objects do
		if objects[i][1] == 1 then
			if objects[i][2] <= x_pos+24 and objects[i][2] >= x_pos-24 and objects[i][3] <= x_pos-24 and objects[i][3] >= x_pos+24 then
				table.remove(objects, i)
				hp = hp + 20
			end
		end
	end
end	

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end