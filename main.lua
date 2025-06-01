function love.load()
	game_state = 0
	hp = 200
	bolt_tex = love.graphics.newImage("res/bolt.png")
	ship_tex = love.graphics.newImage("res/ship.png")
	ast_tex1 = love.graphics.newImage("res/asteroid01.png")
	x_pos = 1024/2
	y_pos = 576/2
	rot = 0
	x_sp = 0
	y_sp = 0
	bolt_cd = 0
	ast_cd = 2
	math.randomseed(os.time())
	bolts = {}
	asteroids = {}
	to_remove_bolts = nil
	to_remove_asts = nil
end

function love.draw()
	love.graphics.clear(0, 0, 0) --Очищаем BG (чтобы пропадали удаленные объекты)
	--Отрисовка объектов
	for i = 1, #bolts do
		if bolts[i] ~= nil then
			tex = bolt_tex
			love.graphics.draw(tex, bolts[i][1], bolts[i][2], 0, 1, 1, 8, 8)
		end
	end
	for i = 1, #asteroids do
		if asteroids[i] ~= nil then
			tex = ast_tex1
			love.graphics.draw(tex, asteroids[i][1], asteroids[i][2], 0, 1, 1, 16, 16)
		end
	end
	hp_bar = love.graphics.rectangle("fill", 5, 5, hp*2, 20) --Рисуем ХП
	ship = love.graphics.draw(ship_tex, x_pos, y_pos, r, 1, 1, 16, 16)
end

function love.update(dt)
	--База
	r = rot * math.pi / 180
	if bolt_cd < 1 then
		table.insert(bolts, {math.random(0, 1024-16), math.random(33, 576-16)})
		bolt_cd = 10
		--print(bolt_cd)
	else
		bolt_cd = bolt_cd - 3*dt
		--print(bolt_cd)
	end	
	
	if ast_cd < 1 then --Спавн астероидов
		storona = math.random(1, 4)
		if storona == 1 then
			table.insert(asteroids, {math.random(0, 1024-16), -40, math.random(-5, 5), math.random(-10, 0), 1})
		elseif storona == 2 then
			table.insert(asteroids, {1060, math.random(0, 576), math.random(-10, 0), math.random(-5, 5), 2})
		elseif storona == 3 then
			table.insert(asteroids, {math.random(0, 1024+16), 600, math.random(5, 5), math.random(0, 10), 3})
		elseif storona == 4 then
			table.insert(asteroids, {-40, math.random(0, 576), math.random(0, 10), math.random(-5, 5), 4})
		end
		ast_cd = 5
		print("Сторона: ".. storona)
	else
		ast_cd = ast_cd - 3*dt
		--print(bolt_cd)
	end	
	
	if hp > 0 then
		hp = hp-5*dt
	end
	x_pos = x_pos + x_sp*dt
	y_pos = y_pos + y_sp*dt
	
	for i = 1, #asteroids do --Движение астероидов
		if asteroids[i] ~= nil then
			asteroids[i][1] = asteroids[i][1] + asteroids[i][3]*(dt*30)
			asteroids[i][2] = asteroids[i][2] + asteroids[i][4]*(dt*30)
		end	
	end
	
	for i = 1, #asteroids do --Уничтожение лишних астероидов
		if asteroids[i][5] == 1 and asteroids[i][2] > 600 then
			table.remove(asteroids, i)
			break
		elseif asteroids[i][5] == 2 and asteroids[i][1] < -40 then
			table.remove(asteroids, i)
			break
		elseif asteroids[i][5] == 3 and asteroids[i][2] < -40 then
			table.remove(asteroids, i)
			break
		elseif asteroids[i][5] == 4 and asteroids[i][1] > 1060 then
			table.remove(asteroids, i)
			break
		end
	end
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
	if to_remove_bolts ~= nil then
		table.remove(bolts, to_remove_bolts)
		to_remove_bolts = nil
	end
	for i = 1, #bolts do
		if bolts[i][1] <= x_pos+24 and bolts[i][1] >= x_pos-24 and bolts[i][2] >= y_pos-24 and bolts[i][2] <= y_pos+24 then
			to_remove_bolts = i
			hp = hp + 20
		end
	end
	
	if to_remove_asts ~= nil then
		table.remove(asteroids, to_remove_asts)
		to_remove_asts = nil
	end
	for i = 1, #asteroids do
		if asteroids[i][1] <= x_pos+40 and asteroids[i][1] >= x_pos-40 and asteroids[i][2] >= y_pos-40 and asteroids[i][2] <= y_pos+40 then
			to_remove_asts = i
			hp = hp - 40
		end
	end
end	

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end