--[[
================================================================================
  CASO DE USO: Gerenciador de Leaderboard - CS2D Football Game
  Responsabilidade: Gerenciar exibição do ranking de artilheiros
  
  Este use case coordena:
  - Carregar estatísticas
  - Exibir top jogadores
  - Atualizar HUD do leaderboard
================================================================================
--]]

local LeaderboardHandler = {}

-- Dependências
local Config = require("src.modules.core.config")
local StatsRepository = require("src.modules.repositories.stats_repository")
local PlayerRepository = require("src.modules.repositories.player_repository")
local ImageUtils = require("src.modules.utils.image_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Atualizar exibição do leaderboard
function LeaderboardHandler:update_leaderboard(state)
	-- Limpar HUD anterior
	for _, img in ipairs(state.stats.leaderboard_hud) do
		ImageUtils:free(img)
	end
	state.stats.leaderboard_hud = {}
	
	-- Obter top 3 jogadores
	local top3 = StatsRepository:get_top_players(state.stats.player_stats, Config.LEADERBOARD.top_count)
	
	-- Posições do HUD
	local screen_width = 680
	local hud_width = 170
	local hud_x = screen_width - hud_width + 120
	local hud_y = 0
	local hud_header_height = 30
	local hud_row_height = 25
	
	-- Criar fundo do cabeçalho
	local header_bg = ImageUtils:create(Config.GRAPHICS.block, hud_x + hud_width/2, hud_y + hud_header_height/2, 2)
	ImageUtils:color(header_bg, 0, 0, 0)
	ImageUtils:scale(header_bg, hud_width / 32, hud_header_height / 32)
	ImageUtils:alpha(header_bg, 0.8)
	table.insert(state.stats.leaderboard_hud, header_bg)
	
	-- Título
	local title_y = hud_y + 10
	for _, pid in ipairs(PlayerRepository:get_all_players()) do
		if player(pid, "exists") then
			parse('hudtxt2 ' .. pid .. ' 10 "' .. Config.TEXTS.leaderboard_title .. '" ' .. (hud_x + hud_width/2) .. ' ' .. title_y .. ' 1')
		end
	end
	
	-- Lista de jogadores
	if #top3 == 0 then
		local empty_y = hud_y + hud_header_height + 10
		for _, pid in ipairs(PlayerRepository:get_all_players()) do
			if player(pid, "exists") then
				parse('hudtxt2 ' .. pid .. ' 11 "' .. Config.TEXTS.leaderboard_empty .. '" ' .. (hud_x + hud_width/2) .. ' ' .. empty_y .. ' 1')
			end
		end
	else
		for i, data in ipairs(top3) do
			-- Criar fundo para cada linha
			local row_y = hud_y + hud_header_height + (i - 1) * hud_row_height
			local row_bg = ImageUtils:create(Config.GRAPHICS.block, hud_x + hud_width/2, row_y + hud_row_height/2, 1)
			ImageUtils:color(row_bg, 0, 0, 0)
			ImageUtils:scale(row_bg, hud_width / 32, hud_row_height / 32)
			ImageUtils:alpha(row_bg, 0.75)
			table.insert(state.stats.leaderboard_hud, row_bg)
			
			-- Cor baseada na posição
			local color = ""
			if i == 1 then
				color = "©255215000"  -- Ouro
			elseif i == 2 then
				color = "©192192192"  -- Prata
			elseif i == 3 then
				color = "©205127050"  -- Bronze
			end
			
			-- Texto
			local name = data.name or PlayerRepository:get_player_name_by_id(data.id, state.stats.player_stats)
			local text = i .. ". " .. name .. " - " .. data.gols .. " gols"
			local text_y = row_y + 12
			
			for _, pid in ipairs(PlayerRepository:get_all_players()) do
				if player(pid, "exists") then
					parse('hudtxt2 ' .. pid .. ' ' .. (10 + i) .. ' "' .. color .. text .. '" ' .. (hud_x + 10) .. ' ' .. text_y .. ' 0')
				end
			end
		end
	end
end

-- Carregar estatísticas do arquivo
function LeaderboardHandler:load_stats(state)
	state.stats.player_stats = StatsRepository:load()
end

-- Retornar módulo
return LeaderboardHandler
