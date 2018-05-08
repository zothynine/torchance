pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--torchance
--mario zoth, klemens kunz

--todo:
--		- score
--	 -	kick screen
--    - kicking animation
--    - goal or miss logic
--    - goal or miss painting
--				- ?bigger bar on start
--				- random goalie actions
--				- learning goalie

--  - start screen
--		- screen setup
				
--  - juicyness
--    - fade out on mode change
--				- particles
--				- screenshake

--  - sfx/music
--  - finalize gfx

--  - nice to have
--				- oefb mode
--				- highscores (local)

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
	--show start hint
	blink_hint_txt()
	rectfill(0,60,127,72,7)
	print("starten mit [x]",34,64,hint.txtcol)
end
-->8
--aim

function update_aim()
		player.x = ball.x-3
	
	
	if ball.y > ball.ty then
		ball.y-=1
		player.y = ball.y+player.runin
	elseif player.runin > 10 then
		player.runin -= 1
		player.y = ball.y+player.runin
	else
		ball.inplace = true
	end
	
	if ball.inplace then
		xdown = btn(5)	
		check_fresh()
	end

	if xdown and not fresh then
		aiming.started = true
	end
	
	if not xdown
				and aiming.started then
		aiming.ended = true
	end

	if aiming.started
				and not aiming.ended then
		
		if aiming.x <= 0
					or aiming.x >= 127 then
			aiming.direction = aiming.direction * -1
		end
		
		aiming.x = aiming.x+aiming.direction*-1
		
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
	--goal top
	draw_goal_top()
	if ball.inplace then
		--aiming line
		line(aiming.x,3,ball.x,ball.y,1)
	end
	--ball
	if not ball.inplace
				and timer.frames%6 == 0 then
 	if ball.pat == ball.smallp then
 		ball.pat = ball.smallp2
 	else
 		ball.pat = ball.smallp
 	end
 end
	fillp(ball.pat)
	circfill(ball.x,ball.y,ball.r,ball.col)
	fillp()
	--player
	spr(1,player.x,player.y,1,1)
	pal(8,1)
	--goalie
	spr(1,49,2,2,2,1,1)
	pal()
	
	--show aiming hint
	if ball.inplace and not aiming.started then
	 blink_hint_txt()
		rectfill(0,0,127,12,7)
		print("halte [x] um zu zielen",22,4,hint.txtcol)
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

	if kicking.ended then
		if kicking.stren >= 60 then
			shot.overshot = true
			shot.miss = true
			ball.minx = -4
		end

		if player.y > ball.y
					and not player.fixed then
			player.y -= 1
		elseif ball.y > ball.miny then
			local ballspeed = kicking.stren/10
			player.fixed = true
			ball.ang = atan2(aiming.x-ball.x, ball.miny-ball.y)
			ball.x = ball.x + ballspeed * cos(ball.ang)
			ball.y = ball.y + ballspeed * sin(ball.ang)
		end
	end
end

function draw_kick()
	local _y = kicking.bary
	--goal top
	if not shot.overshot then
		--ball
		fillp(ball.smallp)
		circfill(ball.x,ball.y,ball.r,ball.col)
		fillp()
	end
	draw_goal_top()
	--aiming line
	line(aiming.x,3,ball.x,ball.y,1)
	if shot.overshot then
		--ball
		fillp(ball.smallp)
		circfill(ball.x,ball.y,ball.r,ball.col)
		fillp()
	end
	--player
	spr(1,player.x,player.y,1,1)
	pal(8,1)
	--goalie
	spr(1,49,2,2,2,1,1)
	pal()

	-- strength bar
	rectfill(122,60,125,125,7)
	rectfill(123,61,124,124,10)
	rectfill(123,61,124,71,9)
	rectfill(123,61,124,63,8)
	line(121,_y,126,_y,1)

	--debug
	color(7)
	print(ball.ang)
	print(cos(ball.ang))
	print(sin(ball.ang))
	--print(player.y)
	--print(kicking.ended)
	--print(aiming.x)
	--print(tostr(kicking.started)..","..tostr(kicking.ended))
	--print(kicking.stren)
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
	timer.frames += 1
	if timer.frames == 59 then
		timer.frames = 0
	end

	if mode == "start" then
		update_start()
	elseif mode == "aim" then
		update_aim()
	elseif mode == "kick" then
		update_kick()
	end
end

function _draw()
	cls()
	draw_grass()
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
	
	timer = {
		frames = 0
	}
	
	player = {
		x = 59,
		y = 113,
		runin = 30,
		fixed = false
	}
	
	aiming = {
		direction = 0.1,
		full = 6,
		started = false,
		ended = false,
		x = 62
	}
	
	kicking = {
		started = false,
		ended = false,
		stren = 0,
		full = 62,
		velo = 0.1,
		bary = 124
	}
	
	ball = {
		r = 2,
		miny = 3,
		x = mid(6,flr(rnd(110)),110),
		dx = 1,
		y = 130,
		ty = 60+flr(rnd(50)),
		inplace = false,
		col = 0x57,
		bigp = 0b0011001111001100,
		bigp2 = 0b1100110000110011,
		smallp = 0b0101101001011010,
		smallp2 = 0b1010010110100101,
		pat = nil
	}
	
	shot = {
		miss = false,
		overshot = false
	}

	hint = {
		colors = {7,6,5,5,6},
		colpos = 1,
		txtcol = nil,
		blinktimer = 0
	}
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
