library.New("blueprints", cw)

local stored = cw.blueprints.stored or {}
cw.blueprints.stored = stored

local CLASS_TABLE = {__index = CLASS_TABLE}
CLASS_TABLE.name = "Base Blueprint"
CLASS_TABLE.skin = 0
CLASS_TABLE.model = "models/error.mdl"
CLASS_TABLE.category = "Other"
CLASS_TABLE.description = "Description."
CLASS_TABLE.craftplace = "cw_crafttable"
CLASS_TABLE.reqatt = {}
CLASS_TABLE.updatt = {}
CLASS_TABLE.required = {}
CLASS_TABLE.recipe = {}
CLASS_TABLE.finish = {}
CLASS_TABLE.requirements = {}

function CLASS_TABLE:GetRequiredAttributes()
	return self.reqatt
end

function CLASS_TABLE:GetUpdateAttributes()
	return self.updatt
end

function CLASS_TABLE:GetRequiredItems()
	return self.required
end

function CLASS_TABLE:GetMaterials()
	return self.recipe
end

function CLASS_TABLE:GetResult()
	return self.finish
end

function CLASS_TABLE:__call(varName, failSafe)
	return (self[varName] != nil and self[varName] or failSafe)
end

function CLASS_TABLE:Register()
	return cw.blueprints:Register(self)
end

function cw.blueprints:GetAll()
	return stored
end

function cw.blueprints:FindByID(identifier)
	if (identifier and identifier != 0 and type(identifier) != "boolean") then
		if (stored[identifier]) then
			return stored[identifier]
		end

		local lowerName = string.lower(identifier)
		local bpTable = nil

		for k, v in pairs(stored) do
			local Name = v.name

			if (string.find(string.lower(Name), lowerName)
			and (!bpTable or string.utf8len(Name) < string.utf8len(bpTable("name")))) then
				bpTable = v
			end
		end

		return bpTable
	end
end

function cw.blueprints:New()
	local object = cw.core:NewMetaTable(CLASS_TABLE)
	return object
end

function cw.blueprints:Register(blueprint)
	blueprint.uniqueID = string.lower(string.gsub(blueprint.uniqueID or string.gsub(blueprint.name, "%s", "_"), "['%.]", ""))
	stored[blueprint.uniqueID] = blueprint

	if (blueprint.model) then
		if SERVER then
			cw.core:AddFile(blueprint.model)
		end
	end
end