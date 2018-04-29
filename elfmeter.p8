pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--elfmeter
--mario zoth, klemens kunz

--todo:
--  - start screen
--	 -	kick screen
--  - better sprites
--  - sfx/music
--  - juicyness
--    - fade out start on [x]
--    - fadein aiming

function check_fresh()
	if not xdown and fresh then
		fresh = false
	end
end

function draw_grass()
	map(0,0,0,0,16,16)
end

function draw_goal_top()
	fillp(0b0011001111001100.1)
	rectfill(30,-1,95,8,0x07)
	fillp()
	rect(30,-1,95,8,7)
end

--juicyness

--blink hint texts
function blink_hint_txt()
	
	if hint.blinktimer == 8 then
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
		mode = "aim"
	end
end

function draw_start()
	cls()
	draw_grass()
		
	--show start hint
	blink_hint_txt()
	rectfill(0,60,127,72,7)
	print("starten mit [x]",34,64,hint.txtcol)
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
		
		if aim_x <= 0
					or aim_x >= 127 then
			aiming.direction = aiming.direction * -1
		end
		
		aim_x = aim_x+aiming.direction*-1		
		
		if abs(aiming.direction) < aiming.full then
			if aiming.direction < 0 then
					aiming.direction -= 0.1
			else
					aiming.direction += 0.1
			end
		end
	end
	
	if aiming.ended then
		fresh = true
		mode = "kick"
	end
end

function draw_aim()
	cls()
	draw_grass()
	--goal top
	draw_goal_top()
	--aiming line
	line(aim_x,26,ball.x,ball.y,1)
	--ball
	fillp(ball.smallp)
	circfill(ball.x,ball.y,ball.r,ball.col)
	fillp()
	--player
	spr(1,player.x,player.y,1,1)
	pal(8,1)
	--goalie
	spr(1,49,2,2,2,1,1)
	pal()
	
	--show aiming hint
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
	
	if kicking.started
		and not kicking.ended then
		
		kicking.stren+=kicking.velo
		kicking.bary-=kicking.velo
		kicking.velo+=0.1
		if kicking.velo >=2.5 then
			kicking.velo = 2.5
		end
		
		if kicking.stren >= kicking.full then
			kicking.bary = kicking.full
			kicking.ended = true
		end	
	end
end

function draw_kick()
	local _y = kicking.bary
	cls()
	draw_grass()
	-- strength bar
	rectfill(122,60,125,125,7)
	rectfill(123,61,124,124,10)
	rectfill(123,61,124,71,9)
	rectfill(123,61,124,63,8)
	line(121,_y,126,_y,1)
	
	--debug
	color(7)
	print(aim_x)
	print(tostr(kicking.started)..","..tostr(kicking.ended))
	print(kicking.stren)
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

function _update60()
	if mode == "start" then
		update_start()
	elseif mode == "aim" then
		update_aim()
	elseif mode == "kick" then
		update_kick()
	end

end

function _draw()
	if mode == "start" then
		draw_start()
	elseif mode == "aim" then
		draw_aim()
	elseif mode == "kick" then
		draw_kick()
	end
end

function _init()
	mode = "start"
	xdown = false
	fresh = true
	player = {}
	kicking = {}
	aiming = {}
	hint = {}
	ball = {}
	player.x = 59
	player.y = 113
	aiming.direction = 0.1
	aiming.full = 6
	aiming.started = false
	aiming.ended = false
	aim_x = 62
	kicking.started = false
	kicking.ended = false
	kicking.stren = 0
	kicking.full = 62
	kicking.velo = 0.1
	kicking.bary = 124
	hint.colors = {7,6,5,5,6}
	hint.colpos = 1
	hint.txtcol = hint.colors[1]
	hint.blinktimer = 0
	ball.r = 2
	ball.x = 62
	ball.y = 88
	ball.col = 0x57
	ball.bigp = 0b0011001111001100
	ball.smallp = 0b0101101001011010
end

__gfx__
000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
000000000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
007007008555558000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
000770008555558000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
000770000055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbb
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
