local COMMAND = cw.command:New("SetCombineLockRank")
COMMAND.tip = "#Command_Setcombinelockrank_Description"
COMMAND.text = "#Command_Setcombinelockrank_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(combine, arguments)
	if (combine:GetFaction() == FACTION_MPF) then
		if Schema:IsPlayerCombineRank(combine, {"CmD","SeC", "MaJ"}) then
			local combinelock = combine:GetEyeTrace().Entity
			if combinelock:GetClass() == "cw_combinelock" then
				local crank = arguments[1]
				local rank = crank != "" and crank or nil
				if rank then
					local sep = string.Explode("/",rank)
					rank = sep
				end
				combinelock:SetCPRank(rank)
				cw.player:Notify(combine, L("CombineLock_RestrictedFor").." "..table.ToString(rank))
			else
				cw.player:Notify(combine, L("CombineLock_MustLookAt"))
			end
		end
	end
end

COMMAND:Register()
