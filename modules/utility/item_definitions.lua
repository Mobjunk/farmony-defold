local item_definitions = {}

item_definitions.definitions = {}

function item_definitions.initilize()
	if next(item_definitions.definitions) then
		return
	end
	local json_content = sys.load_resource("/resources/item_definitions.json")
	if json_content then
		local list = json.decode(json_content)
		item_definitions.definitions = {}
		for i = 1, #list do
			local definition = list[i]
			item_definitions.definitions[definition.id] = definition
		end
	else
		print("Failed to load item_definitions JSON file")
	end
end

function item_definitions.get(id)
	return item_definitions.definitions[id]
end

function item_definitions.is_carried(id)
	local definition = item_definitions.get(id)
	return definition ~= nil and (definition.type == "Object" or definition.type == "Seed")
end

return item_definitions
