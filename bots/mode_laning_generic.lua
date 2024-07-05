
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local X = {}
local bot = GetBot()
local nTpSolt = 15

function GetDesire()
	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then
		return 1
	end
	
	-- if pinged to defend base.
	local ping = Utils.IsPingedToDefenseByAnyPlayer(bot, 4)
	if ping ~= nil then
		local tps = bot:GetItemInSlot(nTpSolt)
		local bestTpLoc = J.GetNearbyLocationToTp(ping.location)
		if tps ~= nil and tps:IsFullyCastable()
			and GetUnitToLocationDistance(bot, bestTpLoc) > 2000
		then
			bot:Action_UseAbilityOnLocation(tps, bestTpLoc + RandomVector(200))
		else
			bot:Action_MoveToLocation(bestTpLoc + RandomVector(200));
		end
		return 0.1
	end

	-- note if bot has 0 desire for laning, they perform like idle - stand still, direct move or simple attack.
	local botName = bot:GetUnitName()
	if Utils.ActuallyBuggedHeroes[botName] ~= nil then return 0 end
	if bot.isBuggyHero == nil then bot.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[botName] ~= nil end
	if bot.isBuggyHero then
		local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
		if GetUnitToLocationDistance(bot, assignedLaneLoc) > 1000 then
			print('[ERROR] '..botName..' is actually bugged.')
			Utils.ActuallyBuggedHeroes[botName] = true
		end
		return 0
	end

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if currentTime <= 10
	then
		return 0.268
	end
	
	if currentTime <= 9 * 60
		and botLV <= 7
	then
		return 0.446
	end
	
	if currentTime <= 12 * 60
		and botLV <= 11
	then
		return 0.369
	end
	
	if botLV <= 17
	then
		return 0.228
	end

	return 0

end
