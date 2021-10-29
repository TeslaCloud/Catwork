PLUGIN:SetGlobalAlias("cwFactories")

if SERVER then
	function cwFactories:EntityHandleMenuOption(player, entity, option, arguments)
		local factory = entity.IsFactory

		if factory then
			if arguments == "cwFactoriesStart" then
				if !entity:GetIsWorking() then
					entity:StartWork()
				end
			elseif arguments == "cwFactoriesStop" then
				if entity:GetIsWorking() then
					entity:StopWork()
				end
			elseif arguments == "cwFactoriesEject" then
				entity:Eject()
			end
		end
	end

	function cwFactories:SaveFactories()
		local garbageRecyclerMetal = {}
		local garbageRecyclerPlastic = {}
		local garbageRecyclerPaper = {}

		for k, v in pairs(ents.FindByClass("cw_factory_garbage_metal")) do
			garbageRecyclerMetal[#garbageRecyclerMetal + 1] = {
				angles = v:GetAngles(),
				position = v:GetPos(),
				productpos = v:GetProductPos(),
				garbagecount = v:GetGarbageCount(),
				ejectstorage = v:GetEjectStorage(),
				garbage = v.Garbages,
			}
		end
		for k, v in pairs(ents.FindByClass("cw_factory_garbage_plastic")) do
			garbageRecyclerPlastic[#garbageRecyclerPlastic + 1] = {
				angles = v:GetAngles(),
				position = v:GetPos(),
				productpos = v:GetProductPos(),
				garbagecount = v:GetGarbageCount(),
				ejectstorage = v:GetEjectStorage(),
				garbage = v.Garbages,
			}
		end
		for k, v in pairs(ents.FindByClass("cw_factory_garbage_paper")) do
			garbageRecyclerPaper[#garbageRecyclerPaper + 1] = {
				angles = v:GetAngles(),
				position = v:GetPos(),
				productpos = v:GetProductPos(),
				garbagecount = v:GetGarbageCount(),
				ejectstorage = v:GetEjectStorage(),
				garbage = v.Garbages,
			}
		end

		cw.core:SaveSchemaData("plugins/factories/metal/" .. game.GetMap(), garbageRecyclerMetal)
		cw.core:SaveSchemaData("plugins/factories/plastic/" .. game.GetMap(), garbageRecyclerPlastic)
		cw.core:SaveSchemaData("plugins/factories/paper/" .. game.GetMap(), garbageRecyclerPaper)
	end
	function cwFactories:LoadFactories()
		local garbageRecyclerMetal = cw.core:RestoreSchemaData("plugins/factories/metal/"..game.GetMap())
		local garbageRecyclerPaper = cw.core:RestoreSchemaData("plugins/factories/paper/"..game.GetMap())
		local garbageRecyclerPlastic = cw.core:RestoreSchemaData("plugins/factories/plastic/"..game.GetMap())

		for k, v in pairs(garbageRecyclerMetal) do
			local device = ents.Create("cw_factory_garbage_metal")

			if device then
				device:SetPos(v.position)
				device:SetAngles(v.angles)
				device:Spawn()
				device:GetPhysicsObject():EnableMotion(false)
				device:SetProductPos(v.productpos)
				device:SetGarbageCount(v.garbagecount)
				device:SetEjectStorage(v.ejectstorage)
				device.Garbages = {}
				for z, x in pairs(v.garbage) do
					device.Garbages[z] = x
				end
			end
		end
		for k, v in pairs(garbageRecyclerPaper) do
			local device = ents.Create("cw_factory_garbage_paper")

			if device then
				device:SetPos(v.position)
				device:SetAngles(v.angles)
				device:Spawn()
				device:GetPhysicsObject():EnableMotion(false)
				device:SetProductPos(v.productpos)
				device:SetGarbageCount(v.garbagecount)
				device:SetEjectStorage(v.ejectstorage)
				device.Garbages = {}
				for z, x in pairs(v.garbage) do
					device.Garbages[z] = x
				end
			end
		end
		for k, v in pairs(garbageRecyclerPlastic) do
			local device = ents.Create("cw_factory_garbage_plastic")

			if device then
				device:SetPos(v.position)
				device:SetAngles(v.angles)
				device:Spawn()
				device:GetPhysicsObject():EnableMotion(false)
				device:SetProductPos(v.productpos)
				device:SetGarbageCount(v.garbagecount)
				device:SetEjectStorage(v.ejectstorage)
				device.Garbages = {}
				for z, x in pairs(v.garbage) do
					device.Garbages[z] = x
				end
			end
		end
	end

	function cwFactories:ClockworkInitPostEntity()
		self:LoadFactories()
	end
	function cwFactories:PostSaveData()
		self:SaveFactories()
	end
else
	function cwFactories:GetEntityMenuOptions(entity, options)
		if entity.IsFactory then
			options["Запустить"] = "cwFactoriesStart"
			options["Остановить"] = "cwFactoriesStop"
			options["Выброс мусора"] = "cwFactoriesEject"
		end
	end
end