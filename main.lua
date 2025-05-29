function love.load()
	hp = 200
	bolt_tex = love.graphics.newImage("res/bolt.png")
	ship_tex = love.graphics.newImage("res/ship.png")
	x_pos = 1024/2
	y_pos = 576/2
	rot = 0
	x_sp = 0
	y_sp = 0
	bolt_cd = 0
	math.randomseed(os.time())
	objects = {}
	to_remove = nil
end

function love.draw()
	love.graphics.clear(0, 0, 0) --Очищаем BG (чтобы пропадали удаленные объекты)
	quad = love.graphics.rectangle("fill", 5, 5, hp*2, 20) --Рисуем ХП
	--Отрисовка объектов
	for i = 1, #objects do
		if objects[i] ~= nil then 
			if objects[i][1] == 1 then
				tex = bolt_tex
			end
			love.graphics.draw(tex, objects[i][2], objects[i][3], 0, 1, 1, 8, 8)
		end
	end
	ship = love.graphics.draw(ship_tex, x_pos, y_pos, r, 1, 1, 16, 16)
end

function love.update(dt)
	--База
	r = rot * math.pi / 180
	if bolt_cd < 1 then
		table.insert(objects, {1, math.random(0, 1024-16), math.random(25, 576-16)})
		bolt_cd = 10
		--print(bolt_cd)
	else
		bolt_cd = bolt_cd - 3*dt
		--print(bolt_cd)
	end	
	if hp > 0 then
		hp = hp-5*dt
	end
	x_pos = x_pos + x_sp*dt
	y_pos = y_pos + y_sp*dt
	
	--Логика движения
	if love.keyboard.isDown("right") then
		x_sp = x_sp + 1
		rot = 90
	elseif love.keyboard.isDown("left") then
		x_sp = x_sp - 1
		rot = 270
	elseif love.keyboard.isDown("up") then
		y_sp = y_sp - 1
		rot = 0
	elseif love.keyboard.isDown("down") then
		y_sp = y_sp + 1
		rot = 180
	elseif love.keyboard.isDown("space") then
		if x_sp > 0 and y_sp > 0 then --Вправо вниз
			if x_sp > y_sp then
				koef = y_sp/x_sp
				x_sp = x_sp - 2
				y_sp = y_sp - 2*koef
			else
				koef = x_sp/y_sp
				x_sp = x_sp - 2*koef
				y_sp = y_sp - 2
			end
		elseif x_sp > 0 and y_sp < 0 then --Вправо вверх
			if x_sp > y_sp*(-1) then
				koef = (y_sp/x_sp)*(-1)
				x_sp = x_sp - 2
				y_sp = y_sp + 2*koef
			else
				koef = (x_sp/y_sp)*(-1)
				x_sp = x_sp - 2*koef
				y_sp = y_sp + 2
			end
		elseif x_sp < 0 and y_sp < 0 then --Влево вверх
			if x_sp < y_sp then
				koef = y_sp/x_sp
				x_sp = x_sp + 2
				y_sp = y_sp + 2*koef
			else
				koef = (x_sp/y_sp)*(-1)
				x_sp = x_sp + 2*koef
				y_sp = y_sp + 2
			end
		elseif x_sp < 0 and y_sp > 0 then --Влево вниз
			if x_sp < y_sp*(-1) then
				koef = (y_sp/x_sp)*(-1)
				x_sp = x_sp + 2
				y_sp = y_sp - 2*koef
			else
				koef = (x_sp/y_sp)*(-1)
				x_sp = x_sp + 2*koef
				y_sp = y_sp - 2
			end
		end
	end
	
	--Проверка коллизий
	--print(to_remove)
	if to_remove ~= nil then
		table.remove(objects, to_remove)
		to_remove = nil
	end
	for i = 1, #objects do
		
		if objects[i][1] == 1 then
			if objects[i][2] <= x_pos+24 and objects[i][2] >= x_pos-24 and objects[i][3] >= y_pos-24 and objects[i][3] <= y_pos+24 then
				to_remove = i
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