--[[
================================================================================
  SERVIÇO DE BOT - CS2D Football Game
  Responsabilidade: Gerenciar IA dos bots
  
  Este serviço encapsula:
  - Comportamento de atacantes e defensores
  - Sistema de papéis dinâmicos
  - Cooldown de chutes
================================================================================
--]]

local BotService = {}

-- Dependências
local Config = require("src.modules.core.config")
local MathUtils = require("src.modules.utils.math_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Atualizar IA de todos os bots
function BotService:update_all(state, player_list)
	-- Atribuir papéis
	self:assign_roles(state, player_list)
	
	-- Atualizar comportamento de cada bot
	for _, id in ipairs(player_list) do
		if player(id, "bot") and player(id, "exists") and player(id, "health") > 0 then
			self:update_bot(state, id)
		end
	end
end

-- Atribuir papéis aos bots (atacante/defensor)
function BotService:assign_roles(state, player_list)
	for _, id in ipairs(player_list) do
		if player(id, "bot") and player(id, "exists") then
			ai_aim(id, state.ball.x, state.ball.y)
			local team = player(id, "team")
			local dist = MathUtils:distance(player(id, "x"), player(id, "y"), state.ball.x, state.ball.y)
			
			-- Bot mais próximo vira atacante
			local closest_to_ball = true
			for _, other_id in ipairs(player_list) do
				if other_id ~= id and player(other_id, "bot") and player(other_id, "team") == team then
					local other_x = player(other_id, "x")
					local other_y = player(other_id, "y")
					local other_dist = MathUtils:distance(other_x, other_y, state.ball.x, state.ball.y)
					if other_dist < dist then
						closest_to_ball = false
						break
					end
				end
			end
			
			state.bots.roles[id] = closest_to_ball and "attacker" or "defender"
		end
	end
end

-- Atualizar comportamento de um bot
function BotService:update_bot(state, id)
	local px = player(id, "x")
	local py = player(id, "y")
	local team = player(id, "team")
	
	-- Inicializar
	if not state.bots.kick_cooldown[id] then
		state.bots.kick_cooldown[id] = 0
	end
	if not state.bots.roles[id] then
		state.bots.roles[id] = "attacker"
	end
	
	-- Diminuir cooldown
	if state.bots.kick_cooldown[id] > 0 then
		state.bots.kick_cooldown[id] = state.bots.kick_cooldown[id] - 1
	end
	
	-- Calcular distância até a bola
	local dist_to_ball = MathUtils:distance(px, py, state.ball.x, state.ball.y)
	
	-- Determinar posições dos gols
	local own_goal_x, own_goal_y, enemy_goal_x, enemy_goal_y
	if team == 1 then
		own_goal_x = MathUtils:tile_to_pixel(Config.GOALS.t.tilex)
		own_goal_y = MathUtils:tile_to_pixel(Config.GOALS.t.tiley)
		enemy_goal_x = MathUtils:tile_to_pixel(Config.GOALS.ct.tilex)
		enemy_goal_y = MathUtils:tile_to_pixel(Config.GOALS.ct.tiley)
	else
		own_goal_x = MathUtils:tile_to_pixel(Config.GOALS.ct.tilex)
		own_goal_y = MathUtils:tile_to_pixel(Config.GOALS.ct.tiley)
		enemy_goal_x = MathUtils:tile_to_pixel(Config.GOALS.t.tilex)
		enemy_goal_y = MathUtils:tile_to_pixel(Config.GOALS.t.tiley)
	end
	
	parse('setweapon ' .. id .. ' 50')
	
	-- Comportamento baseado no papel
	if state.bots.roles[id] == "attacker" then
		self:attacker_behavior(state, id, px, py, dist_to_ball, enemy_goal_x, enemy_goal_y)
	else
		self:defender_behavior(state, id, px, py, dist_to_ball, own_goal_x, own_goal_y, enemy_goal_x, enemy_goal_y)
	end
end

-- Comportamento do atacante
function BotService:attacker_behavior(state, id, px, py, dist_to_ball, enemy_goal_x, enemy_goal_y)
	-- Perseguir a bola
	if dist_to_ball > 20 then
		local angle = MathUtils:angle(px, py, state.ball.x, state.ball.y)
		local new_x = px + math.sin(math.rad(angle)) * Config.BOT.speed
		local new_y = py + math.cos(math.rad(angle)) * Config.BOT.speed
		parse('setpos ' .. id .. ' ' .. new_x .. ' ' .. new_y)
	end
	
	-- Chutar em direção ao gol
	if dist_to_ball <= 50 and state.bots.kick_cooldown[id] == 0 then
		local dir = MathUtils:angle(state.ball.x, state.ball.y, enemy_goal_x, enemy_goal_y)
		state.ball.mx = math.sin(math.rad(dir)) * (Config.BALL.kickspeed * Config.BOT.kick_power_attacker)
		state.ball.my = math.cos(math.rad(dir)) * (Config.BALL.kickspeed * Config.BOT.kick_power_attacker)
		state.ball.rotspeed = Config.BALL.kickrotspeed * 0.7
		state.bots.kick_cooldown[id] = Config.BOT.kick_cooldown_attacker
		state.goal.last_ball_toucher = id
	end
end

-- Comportamento do defensor
function BotService:defender_behavior(state, id, px, py, dist_to_ball, own_goal_x, own_goal_y, enemy_goal_x, enemy_goal_y)
	if dist_to_ball < 120 then
		-- Se a bola está perto, vai direto nela
		local angle = MathUtils:angle(px, py, state.ball.x, state.ball.y)
		local new_x = px + math.sin(math.rad(angle)) * Config.BOT.speed
		local new_y = py + math.cos(math.rad(angle)) * Config.BOT.speed
		parse('setpos ' .. id .. ' ' .. new_x .. ' ' .. new_y)
		
		-- Chutar para o gol adversário
		if dist_to_ball <= 50 and state.bots.kick_cooldown[id] == 0 then
			local dir = MathUtils:angle(state.ball.x, state.ball.y, enemy_goal_x, enemy_goal_y)
			state.ball.mx = math.sin(math.rad(dir)) * (Config.BALL.kickspeed * Config.BOT.kick_power_defender)
			state.ball.my = math.cos(math.rad(dir)) * (Config.BALL.kickspeed * Config.BOT.kick_power_defender)
			state.ball.rotspeed = Config.BALL.kickrotspeed * 0.5
			state.bots.kick_cooldown[id] = Config.BOT.kick_cooldown_defender
			state.goal.last_ball_toucher = id
		end
	else
		-- Se longe, vai para posição defensiva
		local def_x = own_goal_x + (state.ball.x - own_goal_x) * 0.4
		local def_y = own_goal_y + (state.ball.y - own_goal_y) * 0.4
		local angle = MathUtils:angle(px, py, def_x, def_y)
		local new_x = px + math.sin(math.rad(angle)) * Config.BOT.speed
		local new_y = py + math.cos(math.rad(angle)) * Config.BOT.speed
		parse('setpos ' .. id .. ' ' .. new_x .. ' ' .. new_y)
	end
end

-- Retornar módulo
return BotService
