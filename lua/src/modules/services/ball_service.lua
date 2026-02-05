--[[
================================================================================
  SERVIÇO DA BOLA - CS2D Football Game
  Responsabilidade: Gerenciar toda a lógica relacionada à bola
  
  Este serviço encapsula:
  - Física e movimento da bola
  - Colisões com paredes e jogadores
  - Inicialização e reset da bola
================================================================================
--]]

local BallService = {}

-- Dependências
local Config = require("src.modules.core.config")
local MathUtils = require("src.modules.utils.math_utils")
local ImageUtils = require("src.modules.utils.image_utils")
local SoundUtils = require("src.modules.utils.sound_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Inicializar bola
function BallService:initialize(state)
	state.ball.x = Config.BALL.xstart
	state.ball.y = Config.BALL.ystart
	state.ball.mx = 0.0
	state.ball.my = 0.0
	state.ball.lastx = Config.BALL.xstart
	state.ball.lasty = Config.BALL.ystart
	state.ball.xtile = 0
	state.ball.ytile = 0
	state.ball.rot = 0
	state.ball.rotspeed = 0
	
	-- Criar imagem da bola
	if state.ball.img and state.ball.img > 0 then
		ImageUtils:free(state.ball.img)
	end
	state.ball.img = ImageUtils:create(Config.GRAPHICS.ball, Config.BALL.xstart, Config.BALL.ystart, 0)
end

-- Resetar bola (após gol)
function BallService:restart(state)
	self:initialize(state)
	SoundUtils:play(Config.SOUNDS.apito)
	
	-- Limpar indicador da bola
	if state.goal.ball_holder_indicator and state.goal.ball_holder_indicator > 0 then
		ImageUtils:free(state.goal.ball_holder_indicator)
		state.goal.ball_holder_indicator = 0
	end
	
	-- Limpar last_ball_toucher
	state.goal.last_ball_toucher = nil
	
	-- Resetar sistema de explosão e gol
	state.goal.scored = false
	state.explosion.active = false
end

-- Aplicar chute na bola
function BallService:kick(state, player_x, player_y, force_multiplier)
	local dist = MathUtils:distance(player_x, player_y, state.ball.x, state.ball.y)
	
	if dist <= 60 then
		local dir = MathUtils:angle(player_x, player_y, state.ball.x, state.ball.y)
		
		state.ball.mx = math.sin(math.rad(dir)) * Config.BALL.kickspeed * force_multiplier
		state.ball.my = math.cos(math.rad(dir)) * Config.BALL.kickspeed * force_multiplier
		state.ball.rotspeed = Config.BALL.kickrotspeed * force_multiplier
		
		return true
	end
	
	return false
end

-- Verificar colisão com jogadores
function BallService:check_player_collision(state, player_list)
	for _, id in ipairs(player_list) do
		if player(id, "exists") and player(id, "health") > 0 then
			local px = player(id, "x")
			local py = player(id, "y")
			local dist = MathUtils:distance(state.ball.x, state.ball.y, px, py)
			
			-- Colisão detectada
			if dist <= 20 and dist > 0 then
				local dir = MathUtils:angle(px, py, state.ball.x, state.ball.y)
				local push_strength = 3
				
				state.ball.mx = state.ball.mx + math.sin(math.rad(dir)) * push_strength
				state.ball.my = state.ball.my + math.cos(math.rad(dir)) * push_strength
				state.ball.rotspeed = Config.BALL.kickrotspeed * 0.3
				
				-- Registrar quem tocou na bola
				state.goal.last_ball_toucher = id
			end
		end
	end
end

-- Atualizar física da bola
function BallService:update_physics(state)
	-- Adicionar posição
	state.ball.x = state.ball.x + state.ball.mx
	state.ball.y = state.ball.y + state.ball.my
	
	-- Rotação
	state.ball.rot = state.ball.rot + state.ball.rotspeed
	if state.ball.rotspeed > 0 then
		state.ball.rotspeed = state.ball.rotspeed - Config.BALL.friction
	end
	if state.ball.rotspeed < 0 then
		state.ball.rotspeed = 0
	end
	
	if state.ball.rot > 360 then
		state.ball.rot = 0
	end
	
	-- Atualizar tile position
	state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
	state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
	
	-- Verificar colisão com paredes
	if (tile(state.ball.xtile, state.ball.ytile, "wall") == true) or 
	   (tile(state.ball.xtile, state.ball.ytile, "obstacle") == true) then
		local x1, y1, x2, y2
		
		state.ball.x = state.ball.lastx
		state.ball.y = state.ball.lasty
		
		x2, y2 = state.ball.xtile, state.ball.ytile -- WALL
		state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
		state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
		x1, y1 = state.ball.xtile, state.ball.ytile -- FLOOR
		
		local dirx = (x2 == x1) and 0 or 1
		local diry = (y2 == y1) and 0 or 1
		
		if dirx == 1 then 
			state.ball.mx = -state.ball.mx
		end
		
		if diry == 1 then
			state.ball.my = -state.ball.my
		end
		
		state.ball.x = state.ball.x + state.ball.mx
		state.ball.y = state.ball.y + state.ball.my
	end
	
	state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
	state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
	
	-- Aplicar fricção X
	if state.ball.mx > 0 then
		state.ball.mx = state.ball.mx - Config.BALL.friction
		if state.ball.mx < 0 then state.ball.mx = 0 end
	elseif state.ball.mx < 0 then
		state.ball.mx = state.ball.mx + Config.BALL.friction
		if state.ball.mx > 0 then state.ball.mx = 0 end
	end
	
	-- Aplicar fricção Y
	if state.ball.my > 0 then
		state.ball.my = state.ball.my - Config.BALL.friction
		if state.ball.my < 0 then state.ball.my = 0 end
	elseif state.ball.my < 0 then
		state.ball.my = state.ball.my + Config.BALL.friction
		if state.ball.my > 0 then state.ball.my = 0 end
	end
	
	-- Atualizar imagem
	if state.ball.xtile >= 0 and state.ball.ytile >= 0 and 
	   state.ball.xtile < map("xsize") and state.ball.ytile < map("ysize") then
		ImageUtils:position(state.ball.img, state.ball.x, state.ball.y, state.ball.rot)
	else
		state.ball.x = state.ball.lastx
		state.ball.y = state.ball.lasty
		state.ball.mx = -state.ball.mx
		state.ball.my = -state.ball.my
		state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
		state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
		ImageUtils:position(state.ball.img, state.ball.x, state.ball.y, state.ball.rot)
	end
	
	state.ball.lastx = state.ball.x
	state.ball.lasty = state.ball.y
end

-- Congelar bola (durante explosão/replay)
function BallService:freeze(state)
	state.ball.mx = 0
	state.ball.my = 0
	state.ball.rotspeed = 0
end

-- Obter jogador mais próximo da bola
function BallService:get_closest_player(state, player_list)
	local closest_id = nil
	local min_dist = 999999
	
	for _, id in ipairs(player_list) do
		if player(id, "exists") and player(id, "health") > 0 then
			local px = player(id, "x")
			local py = player(id, "y")
			local dist = MathUtils:distance(state.ball.x, state.ball.y, px, py)
			
			if dist < min_dist then
				min_dist = dist
				closest_id = id
			end
		end
	end
	
	return closest_id, min_dist
end

-- Atualizar bola para seguir cursor com raio limitado (domínio da bola)
function BallService:follow_cursor_limited(state, player_id)
	if not player(player_id, "exists") or player(player_id, "health") <= 0 then
		state.ball_control.active = false
		state.ball_control.player_id = nil
		return
	end
	
	local player_x = player(player_id, "x")
	local player_y = player(player_id, "y")
	
	-- Verificar se a bola ainda está dentro do raio de domínio
	local dist_to_player = MathUtils:distance(state.ball.x, state.ball.y, player_x, player_y)
	if dist_to_player > state.ball_control.max_radius then
		-- Perdeu o controle da bola
		state.ball_control.active = false
		state.ball_control.player_id = nil
		return
	end
	
	-- Obter posição do cursor no mapa
	local cursor_x = player(player_id, "mousemapx")
	local cursor_y = player(player_id, "mousemapy")
	
	-- Verificar se as coordenadas são válidas
	if not cursor_x or not cursor_y or cursor_x < 0 or cursor_y < 0 then
		return
	end
	
	-- Calcular a posição alvo (cursor), mas limitada ao raio máximo do jogador
	local dx_to_cursor = cursor_x - player_x
	local dy_to_cursor = cursor_y - player_y
	local dist_cursor_to_player = math.sqrt(dx_to_cursor * dx_to_cursor + dy_to_cursor * dy_to_cursor)
	
	local target_x, target_y
	
	if dist_cursor_to_player > state.ball_control.max_radius then
		-- Cursor está fora do raio, limitar a posição alvo ao limite do raio
		local ratio = state.ball_control.max_radius / dist_cursor_to_player
		target_x = player_x + dx_to_cursor * ratio
		target_y = player_y + dy_to_cursor * ratio
	else
		-- Cursor está dentro do raio, usar posição do cursor
		target_x = cursor_x
		target_y = cursor_y
	end
	
	-- Usar interpolação linear (lerp) para movimento suave
	-- Quanto menor o fator, mais suave (0.1 = muito suave, 0.3 = responsivo)
	local lerp_factor = 0.15
	
	-- Calcular distância até o alvo
	local dx = target_x - state.ball.x
	local dy = target_y - state.ball.y
	local dist = math.sqrt(dx * dx + dy * dy)
	
	-- Verificar se a bola chegou no destino (dentro de 3 pixels)
	if dist < 3 then
		-- Desativar controle automaticamente
		state.ball_control.active = false
		state.ball_control.player_id = nil
		state.ball_control.timer = 0
		
		-- Zerar velocidades para parar a bola
		state.ball.mx = 0
		state.ball.my = 0
		state.ball.rotspeed = state.ball.rotspeed * 0.5
		
		-- Atualizar posição final
		state.ball.x = target_x
		state.ball.y = target_y
		state.ball.lastx = state.ball.x
		state.ball.lasty = state.ball.y
		
		-- Atualizar tile position
		state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
		state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
		
		-- Atualizar posição da imagem
		ImageUtils:position(state.ball.img, state.ball.x, state.ball.y, state.ball.rot)
		return
	end
	
	-- Aplicar interpolação suave
	local new_x = state.ball.x + dx * lerp_factor
	local new_y = state.ball.y + dy * lerp_factor
	
	-- Calcular velocidade atual para mx/my (usado em colisões)
	state.ball.mx = (new_x - state.ball.x) * 0.3
	state.ball.my = (new_y - state.ball.y) * 0.3
	
	-- Atualizar posição
	state.ball.x = new_x
	state.ball.y = new_y
	
	-- Rotação suave proporcional à velocidade
	if dist > 0.5 then
		local move_speed = math.sqrt(state.ball.mx * state.ball.mx + state.ball.my * state.ball.my)
		state.ball.rotspeed = math.min(move_speed * 0.8, 4)
	else
		-- Reduzir rotação gradualmente quando parado
		state.ball.rotspeed = state.ball.rotspeed * 0.85
	end
	
	-- Atualizar rotação
	state.ball.rot = state.ball.rot + state.ball.rotspeed
	if state.ball.rot > 360 then 
		state.ball.rot = state.ball.rot - 360 
	end
	
	-- Atualizar tile position
	state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
	state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
	
	-- Atualizar posição da imagem
	ImageUtils:position(state.ball.img, state.ball.x, state.ball.y, state.ball.rot)
	
	-- Atualizar last position
	state.ball.lastx = state.ball.x
	state.ball.lasty = state.ball.y
end

-- Atualizar bola para seguir cursor do jogador (comando secreto)
function BallService:follow_cursor(state, player_id)
	if not player(player_id, "exists") or player(player_id, "health") <= 0 then
		state.cursor_control.active = false
		state.cursor_control.player_id = nil
		return
	end
	
	-- Obter posição do cursor no mapa usando mousemapx e mousemapy
	local cursor_x = player(player_id, "mousemapx")
	local cursor_y = player(player_id, "mousemapy")
	
	-- Verificar se as coordenadas são válidas (-1 se não disponível)
	if not cursor_x or not cursor_y or cursor_x < 0 or cursor_y < 0 then
		return
	end
	
	-- Mover bola suavemente para a posição do cursor (movimento mais natural)
	local speed = 8  -- Velocidade reduzida para movimento mais suave
	local dx = cursor_x - state.ball.x
	local dy = cursor_y - state.ball.y
	local dist = math.sqrt(dx * dx + dy * dy)
	
	if dist > 1 then
		-- Normalizar e aplicar velocidade suave
		local move_x = (dx / dist) * speed
		local move_y = (dy / dist) * speed
		
		-- Aplicar movimento gradual através de mx/my para parecer natural
		state.ball.mx = move_x * 0.7
		state.ball.my = move_y * 0.7
		
		state.ball.x = state.ball.x + move_x
		state.ball.y = state.ball.y + move_y
		
		-- Rotação proporcional à velocidade de movimento
		state.ball.rotspeed = math.min(dist * 0.1, 5)
	else
		-- Se muito próximo, reduzir movimento para zero suavemente
		state.ball.mx = state.ball.mx * 0.8
		state.ball.my = state.ball.my * 0.8
		state.ball.rotspeed = state.ball.rotspeed * 0.9
	end
	
	-- Atualizar rotação
	state.ball.rot = state.ball.rot + state.ball.rotspeed
	if state.ball.rot > 360 then 
		state.ball.rot = state.ball.rot - 360 
	end
	
	-- Atualizar tile position
	state.ball.xtile = MathUtils:pixel_to_tile(state.ball.x)
	state.ball.ytile = MathUtils:pixel_to_tile(state.ball.y)
	
	-- Atualizar posição da imagem
	ImageUtils:position(state.ball.img, state.ball.x, state.ball.y, state.ball.rot)
	
	-- Atualizar last position
	state.ball.lastx = state.ball.x
	state.ball.lasty = state.ball.y
end

-- Retornar módulo
return BallService
