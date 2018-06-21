pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--torchance
--mario zoth, klemens kunz

--todo:
--		- score
--	 -	kick screen
--				- ?bigger bar on start
--				- random goalie actions

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

function move_ball(down)
 ball.speed = kicking.stren/10
 _velx = ball.speed * cos(ball.ang)
	_vely = ball.speed * sin(ball.ang)

 if shot.done and not shot.missed then
 	if _velx < 0
 				and ball.x-ball.r <= 31 then
 				_velx = 0
 	elseif _velx < 0
 								and ball.x+ball.r >= 89 then
 				_velx = 0
 	end
 end
 
 if down then
 	_vely *= -1
 end
 
 ball.x += _velx
 ball.y += _vely
end

function goalie_reactions()
	local _gxf = flr(goalie.x)
	local _axf = flr(aiming.x)

	if kicking.stren == 0 then	
		shot.tooslow = true
		shot.missed = true
		kicking.stren = -1
	end

	--catch slow ball
	if kicking.stren < 15 then
		
		--slow down ball
		kicking.stren = mid(0,kicking.stren-0.1,kicking.stren)
	end
	
	if kicking.stren < 20 then
		
 	--follow slow ball
 	aiming.draw = false
 	if goalie.x > ball.x then
 		goalie.x -= 1
 	elseif goalie.x < ball.x then
 		goalie.x += 1
 	end

	end
end

function check_catch()
		local _bx = ball.x
		local _by = ball.y-ball.r
		local _gx = goalie.x
		local _gy = goalie.y+5
		local _lvl = goalielvl
		
		if _by <= _gy
					and not shot.overshot then
			if _bx >= _gx-_lvl
						and _bx <= _gx+6+_lvl then
				ball.miny = goalie.y+6
				goalie.catch = true
				goalie.x = ball.x-ball.r
			end
		end
end

function draw_score()
	rectfill(0,0,127,8,1)
	print("chance:"..trys,4,2,7)
--	print("goalielvl:"..goalielvl,40,2,7)
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
	sspr(32,0,74,29,26,38)
end
-->8
--aim

function animate_player_sprite()
		if timer.frames%6==0 then
 		if player.spri==4 then
 			player.spri = 1
 		end
 		player.spri += 1
		end
end

function update_aim()
		player.x = ball.x-3
	
	if ball.y > ball.ty then
		ball.y-=1
		aiming.x = ball.x
		player.y = ball.y+player.runin
		animate_player_sprite()
	elseif player.runin > 10 then
		player.runin -= 1
		player.y = ball.y+player.runin
		animate_player_sprite()
	else
		ball.inplace = true
		player.spri = 1
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
		ball.ang = atan2(aiming.x-ball.x, ball.miny-ball.y)
		mode = "kick"
	end
	
	if ball.inplace then
		aiming.draw = true
	end
end

function draw_aim()
	--goal top
	draw_goal_top()
	if aiming.draw then	
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
	sspr(player.sprx[player.spri],0,7,5,player.x,player.y)
	pal(8,1)
	--goalie
	sspr(player.sprx[1],0,7,5,goalie.x,goalie.y)
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
		
		elseif ball.y > ball.miny
									and kicking.stren > -1
									and not shot.done then

			player.fixed = true
			move_ball(false)
			goalie_reactions()
			check_catch()

			if (ball.y < ball.miny) ball.y = ball.miny

		else
			
			--after kicking
			--find out if catched or missed
			aiming.draw = false
			if ball.y <= 16 and not shot.done then
				shot.done = true

				if (ball.x-ball.r <= gline.l
								and ball.x+ball.r >= gline.l)
							or (ball.x-ball.r <= gline.l
											and ball.x+ball.r >= gline.r) then

						shot.outside = false
						shot.overshot = false
						shot.pole = true
						shot.missed = true
						ball.speed = 2
			
				elseif ball.x-ball.r+1 < gline.l
							or ball.x+ball.r+1 > gline.r then
			
						shot.outside = true
						shot.overshot = false
						shot.pole = false
						shot.missed = true
				end
			end
			
			--start hint timer
			if timer.wait < 120 then
				timer.wait+=1
			
 			--if shot.pole
 			--			and ball.speed > 0 then
 			--	ball.y += ball.speed
 			--	ball.speed -= 0.1
 			--end
 			
 			if shot.pole then
 				move_ball(true)
 			else
 				if shot.missed then
 					ball.miny = 0
 				end
 				if ball.y >= ball.miny then
 					move_ball(false)
 				end
 			end
 			
			else
				timer.wait=0
				--update game mode
 			if shot.missed then
  			trys -= 1
  		else
  			goals += 1
  			goalielvl = mid(0,goalielvl+2,20)
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
	if aiming.draw then
		line(aiming.x,ball.miny,ball.x,ball.y,1)
	end
	
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
	sspr(8,0,7,5,goalie.x,goalie.y)
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
 		elseif shot.tooslow then
 			_goaltxt = "zu wenig power!"
 		end
		end	
	
		draw_hint(_goaltxt,false,60)
	end
	
	--draw goalie skill pointers
	pset(goalie.x-goalielvl,goalie.y+4,8)
	pset(goalie.x+6+goalielvl,goalie.y+4,8)
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
	if _mode == "gameover" then
		goalielvl = 0
	end
 _init()
end

function _init()
	xdown = false
	fresh = true
	
	gline = {
 	y=16,
 	l=30,
 	r=95
	}
	
	timer = {
		frames = 0,
		wait = 0
	}
	
	player = {
		sprx = {8,16,8,24},
		spri = 1,
		x = 59,
		y = 113,
		runin = 30,
		fixed = false
	}
	
	goalie = {
		x = 60,
		y = 22,
		catch = false,
	}
	
	aiming = {
		direction = 0.1,
		full = 6,
		started = false,
		ended = false,
		x = 62,
		draw = false
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
		miny = 16,
		x = mid(6,flr(rnd(110)),110),
		y = 130,
		ty = 60+flr(rnd(50)),
		speed = 0,
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
		tooslow = false,
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
goalielvl = 0
__gfx__
000000000555500005555000055550001111111111111111111111111111111111111111111111111111111111111111111111111100000033333333bbbbbbbb
000000000555550085555500055555801888888888888888811888888888888881188888888888888118888888888888811888888100000033333333bbbbbbbb
007007008555558085555580855555801877777777777777811877777777777781187777777777778118777777777777811877778100000033333333bbbbbbbb
000770008555558005555580855555001877777777777777811877777777777781187777777777778118777777777777811877778100000033333333bbbbbbbb
000770000055500000555000005550001877777777777777811877777777777781187777777777778118777777777777811877778100000033333333bbbbbbbb
007007000000000000000000000000001877777777777777811877777777777781187777777777778118777777777777811877778100000033333333bbbbbbbb
000000000000000000000000000000001888888777788888811877778888777781187777888877778118777788887777811877778100000033333333bbbbbbbb
000000000000000000000000000000001111118777781111111877778888777781187777888877778118777788887777811877778100000033333333bbbbbbbb
00000000000000000000000000000000000001877778111111187777888877778118777788887777811877778888777781187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777888877778118777788887777811877777777777781187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777888877778118777788887777811877777777777781187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777888877778118777788887777811877777777777781188888810000000000000000000000
00000000000000000000000000000000000001877778111111187777888877778118777788887777811877777777777781188888810000000000000000000000
00000000000000000000000000000000000001877778111111187777777777778118777777777777811877778887778881187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777777777778118777777777777811877778187777781187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777777777778118777777777777811877778188877781187777810000000000000000000000
00000000000000000000000000000000000001877778111111187777777777778118777777777777811877778111877781187777810000000000000000000000
00000000000000000000000000000000000001888888111111188888888888888118888888888888811888888111888881188888810000000000000000000000
00000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000
00000000000000000000000000000000000000000000000000001111111111111111111111111111111111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000117777171171777717117177771777711100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017888878178788787817878888788881000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017811178178781787717878111781111000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017811177778777787877878111777111000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017811178878788787887878111788811000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017811178178781787817878111781111000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000017777178178781787817877771777711000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000011888818118181181811818888188881000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000011111111111111111111111111111111000000000000000000000000000000000000000000
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
