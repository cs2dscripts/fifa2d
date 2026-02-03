--[[
================================================================================
  CASO DE USO: Gerenciador de Replay - CS2D Football Game
  Responsabilidade: Gerenciar sistema de replay após gol
  
  Este use case coordena:
  - Iniciar replay após explosão
  - Reproduzir trajetória gravada da bola
  - Posicionar jogadores como espectadores
  - Resetar jogo após replay
================================================================================
--]]

local ReplayHandler = {}

-- Dependências
local Config = require("src.modules.core.config")
local PlayerRepository = require("src.modules.repositories.player_repository")
local BallService = require("src.modules.services.ball_service")
local ImageUtils = require("src.modules.utils.image_utils")
local MathUtils = require("src.modules.utils.math_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Iniciar replay
function ReplayHandler:start_replay(state, scoring_team)
	state.replay.playing = true
	state.replay.recording = false
	state.replay.frame_index = 1
	
	-- Esconder bola real
	if state.ball.img and state.ball.img > 0 then
		ImageUtils:position(state.ball.img, -1000, -1000, 0)
	end
	
	-- Criar imagem para o replay
	if #state.replay.data > 0 then
		state.replay.ball_img = ImageUtils:free(state.replay.ball_img)
		state.replay.ball_img = ImageUtils:create(Config.GRAPHICS.ball, state.replay.data[1].x, state.replay.data[1].y, 0)
		ImageUtils:scale(state.replay.ball_img, 1.2, 1.2)
		ImageUtils:blend(state.replay.ball_img, 1)
	end
	
	-- Criar texto "REPLAY"
	state.replay.text_img = ImageUtils:free(state.replay.text_img)
	state.replay.text_img = ImageUtils:create(Config.GRAPHICS.replay_text, 400, 50, 2)
	
	-- Determinar posição de observação baseada no time
	local watch_x, watch_y
	if scoring_team == "t" then
		watch_x = MathUtils:tile_to_pixel(48)
		watch_y = MathUtils:tile_to_pixel(47)
	else
		watch_x = MathUtils:tile_to_pixel(62)
		watch_y = MathUtils:tile_to_pixel(47)
	end
	
	-- Posicionar jogadores para assistir
	for _, pid in ipairs(PlayerRepository:get_all_players()) do
		if player(pid, "exists") and player(pid, "health") > 0 then
			-- Remover chapéu
			if state.players.hats[pid] then
				ImageUtils:free(state.players.hats[pid])
				state.players.hats[pid] = nil
			end
			
			-- Posicionar e congelar
			parse('setpos ' .. pid .. ' ' .. watch_x .. ' ' .. watch_y)
			parse('speedmod ' .. pid .. ' -100')
			parse('equip ' .. pid .. ' 84')  -- Tornar invisível
		end
	end
end

-- Atualizar replay frame a frame
function ReplayHandler:update_replay(state, player_list)
	if not state.replay.playing or #state.replay.data == 0 then
		return
	end
	
	if state.replay.frame_index <= #state.replay.data then
		-- Atualizar posição da bola
		local frame = state.replay.data[state.replay.frame_index]
		if state.replay.ball_img and state.replay.ball_img > 0 then
			ImageUtils:position(state.replay.ball_img, frame.x, frame.y, frame.rot)
		end
		
		state.replay.frame_index = state.replay.frame_index + 1
	else
		-- Replay terminou
		self:end_replay(state, player_list)
	end
end

-- Finalizar replay e resetar jogo
function ReplayHandler:end_replay(state, player_list)
	state.replay.playing = false
	
	-- Remover imagens do replay
	state.replay.ball_img = ImageUtils:free(state.replay.ball_img)
	state.replay.text_img = ImageUtils:free(state.replay.text_img)
	
	-- Remover texto de HUD
	for _, pid in ipairs(player_list) do
		parse('hudtxt2 ' .. pid .. ' 100 "" 0 0')
	end
	
	-- Restaurar jogadores
	for _, pid in ipairs(player_list) do
		if player(pid, "exists") then
			-- Restaurar velocidade
			parse('speedmod ' .. pid .. ' 0')
			
			-- Remover invisibilidade
			parse('strip ' .. pid .. ' 84')
			
			-- Recriar chapéu
			local team = PlayerRepository:get_player_team(pid)
			if team == 1 then
				state.players.hats[pid] = ImageUtils:create(Config.GRAPHICS.flamengo_hat, 0, 0, 200 + pid)
			elseif team == 2 then
				state.players.hats[pid] = ImageUtils:create(Config.GRAPHICS.corinthians_hat, 0, 0, 200 + pid)
			end
		end
	end
	
	-- Resetar bola
	BallService:restart(state)
	
	-- Reposicionar jogadores
	for _, pid in ipairs(player_list) do
		if player(pid, "exists") and player(pid, "health") > 0 then
			local team = PlayerRepository:get_player_team(pid)
			local new_x = (team == 2) and (45 * 32) or (50 * 32)
			parse('setpos ' .. pid .. ' ' .. new_x .. ' ' .. player(pid, "y"))
		end
	end
	
	-- Limpar dados de replay para nova gravação
	state.replay.data = {}
	state.replay.recording = true
end

-- Retornar módulo
return ReplayHandler
