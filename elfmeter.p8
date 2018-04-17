pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--elfmeter
--mario zoth, klemens kunz

function check_fresh()
	if not xdown and fresh then
		fresh = false
	end
end

function draw_field()
		--grass
	rectfill(0,0,127,127,3)
end

function draw_goal_top()
	fillp(0b0011001111001100.1)
	rectfill(30,5,95,22,0x07)
	fillp()
	rect(30,5,95,22,7)
end

--juicyness
function blink_hint_txt()
	
	if hint.blinktimer == 6 then
	
 	hint.colpos += 1
 	
 	if hint.colpos > #hint.colors then
 		hint.colpos = 1
 	end

 	hint.txtcol = hint.colors[hint.colpos]
 	
 	hint.blinktimer = 0
	end
	
	hint.blinktimer += 1
end
-->8
--start

function update_start()
	if btnp(5) then
		_update60 = update_aim
		_draw = draw_aim
	end
end

function draw_start()
	cls()
	draw_field()
	print("starten mit [x]",35,60,7)
end
-->8
--aim

function update_aim()
	xdown = btn(5)	
	check_fresh()

	if xdown and not fresh then
		aiming.started = true
	end
	
	if not xdown
				and aiming.started then
		aiming.ended = true
	end

	if aiming.started
				and not aiming.ended then
		
		if player.x == 0
					or player.x == 112 then
			aiming.direction = aiming.direction * -1
		end
		
		player.x = player.x+aiming.direction
		aim_x = aim_x+aiming.direction*-1
				
	end
	
	if aiming.ended then
		fresh = true
		_update60 = update_kick
		_draw = draw_kick
	end
end

function draw_aim()
	cls()
	draw_field()
	--aiming line
	line(aim_x-1,26,player.x+7,117,11)
	--goal top
	draw_goal_top()
	--ball
	fillp(4+8+64+128+ 	256+512+4096+8192)
	circfill(61,71,4,0x57)
	fillp()
	--player
	spr(1,player.x,player.y,2,2)
	pal(12,8)
	--goalie
	spr(1,54,20,2,2,1,1)
	pal()
	if not aiming.started then
		blink_hint_txt()
		rectfill(0,60,127,72,7)
		print("halte [x] um zu zielen",22,64,hint.txtcol)
	end

end
-->8
--kick

function update_kick()
	xdown = btn(5)	
	check_fresh()
	
	if xdown and not fresh then
		kicking.started = true
	end
	
	if not xdown
				and kicking.started then
		kicking.ended = true
	end
end

function draw_kick()
	cls()
	draw_field()
	
	--debug
	color(7)
	print(aim_x)
	color()
	--/debug
end

-->8
--4
-->8
--5
-->8
--6
-->8
--initial

function _update60()end

function _draw()end

function _init()
	xdown = false
	fresh = true
	player = {}
	kicking = {}
	aiming = {}
	hint = {}
	player.x = 54
	player.y = 109
	aiming.direction = -1
	aiming.started = false
	aiming.ended = false
	aim_x = 62
	kicking.started = false
	kicking.ended = false
	hint.colors = {15,14,6,14}
	hint.colpos = 1
	hint.txtcol = hint.colors[1]
	hint.blinktimer = 0
	_update60 = update_start
	_draw = draw_start
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000556600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000005556660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000055555666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc5555556666cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc5555555666ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc5555555566ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc5555555556cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cc55555555cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
