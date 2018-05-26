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
				
--  - powerups
--				- hatrick

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

function draw_score()
	rectfill(0,0,127,8,1)
	print("chance:"..trys,4,2,7)
	print("tore:"..goals,88,2,7)
end

function draw_hint(_txt,_doblink,_y)
	local x = (128-(4*#_txt))/2
	local y = 0
	local col = hint.fixedcol
	if (_doblink) col = hint.txtcol
	if (_y ~= nil) y = _y
	if (_doblink) blink_hint_txt()
	rectfill(0,y,127,y+8,1)
	print(_txt,x,y+2,col)
end

function draw_grass()
	map(0,0,0,0,16,16)
end

function draw_goal_top()
	fillp(0b0011001111001100.1)
	rectfill(30,-1,95,16,0x07)
	fillp()
	rect(30,-1,95,16,7)
	rect(19,-1,107,35,7)
	--rect(6,-1,120,55,7)
	line(0,64,127,64,7)
	circfill(62,51,1,7)
	local _r = 24
	clip(62-_r,64,_r*2,_r)
	circ(62,54,_r,7)
	clip()
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
	draw_hint("starten mit [x]",true)
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
		line(aiming.x,ball.miny,ball.x,ball.y,1)
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
	sspr(8,0,7,5,player.x,player.y)
	pal(8,1)
	--goalie
	sspr(8,0,7,5,60,goalie.y)
	pal()
	draw_score()
	
	--show aiming hint
	if ball.inplace
				and not aiming.started then
		draw_hint("halte [x] um zu zielen",true)
	end
	
	if ball.inplace
				and aiming.started
				and not aiming.ended then
		draw_hint("loslassen um zu fixieren",true)
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
			shot.missed = true
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
			
 			if flr(ball.y-3)<=flr(goalie.y+4) then
 						--and ball.x>=golie.x
 						--and ball.x <= goalie.x+7 then
 					ball.miny = ball.y
 					goalie.catch = true
 			end

			if (ball.y < ball.miny) ball.y = ball.miny

		else
			
			--after kicking
			--find out if catched or missed
			if ball.y < 16 then

				if ball.x == 30
							or ball.x == 95 then

						shot.outside = false
						shot.overshot = false
						shot.pole = true
						shot.missed = true
			
				elseif ball.x < 30
							or ball.x > 95 then
			
						shot.outside = true
						shot.overshot = false
						shot.pole = false
						shot.missed = true
				end
			end
			
			--start hint timer
			if timer.wait < 120 then
				timer.wait+=1
			else
				timer.wait=0
				--update game mode
 			if shot.missed then
  			trys -= 1
  		else
  			goals += 1
  		end
  		if trys == 0 then
  			reset_game("gameover")
  		else
  			reset_game("aim")
  		end
			end
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
	line(aiming.x,ball.miny,ball.x,ball.y,1)
	if shot.overshot then
		--ball
		fillp(ball.smallp)
		circfill(ball.x,ball.y,ball.r,ball.col)
		fillp()
	end
	--player
	sspr(8,0,7,5,player.x,player.y)
	pal(8,1)
	--goalie
	sspr(8,0,7,5,60,goalie.y)
	pal()

	-- strength bar
	rectfill(122,60,125,125,7)
	rectfill(123,61,124,124,10)
	rectfill(123,61,124,71,9)
	rectfill(123,61,124,63,8)
	line(121,_y,126,_y,1)
	draw_score()
	
	if not kicking.started then
		draw_hint("halte [x] um auszuholen",true)
	end
	
	if kicking.started
				and not kicking.ended then
		draw_hint("lass los um zu kicken!",true)
	end
	
	--hint after kicking
	if kicking.ended
				and timer.wait > 0 then
		local _goaltxt = "tooooor!"
		
		if goalie.catch then
			_goaltxt = "gehalten!"
		end
		
		if shot.missed then
 		if shot.outside then
 			_goaltxt = "daneben!"
 		elseif shot.pole then
 			_goaltxt = "stange!"
 		elseif shot.overshot then
 			_goaltxt = "zu viel power - ueber das tor!"
 		end
		end	
	
		draw_hint(_goaltxt,false,60)
	end
	
	--debug
	print(flr(ball.y)..":"..flr(goalie.y)..":"..tostr(goalie.catch),5,30,1)
	
end

-->8
--game over
function update_gameover()
	trys = 3
	goals = 0
	if btnp(5) then
		reset_game("aim")
	elseif btnp(4) then
		reset_game("start")
	end
end

function draw_gameover()
	draw_hint("game over",false)
	draw_hint("versuche es nochmal ❎",true,60)
	draw_hint("zum start mit [c]",false,68)
end
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
	elseif mode == "gameover" then
		update_gameover()
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
	elseif mode == "gameover" then
		draw_gameover()
	end
end

function reset_game(_mode)
	mode = _mode
 _init()
end

function _init()
	xdown = false
	fresh = true
	
	timer = {
		frames = 0,
		wait = 0
	}
	
	player = {
		x = 59,
		y = 113,
		runin = 30,
		fixed = false
	}
	
	goalie = {
		y = 22,
		catch = false
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
		miny = 12,
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
		missed = false,
		overshot = false,
		outside = false,
		pole = false,
		done = false
	}

	hint = {
		fixedcol = 7,
		colors = {5,6,7,7,6},
		colpos = 1,
		txtcol = 7,
		blinktimer = 0
	}
end

mode = "start"
trys = 3
goals = 0
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
