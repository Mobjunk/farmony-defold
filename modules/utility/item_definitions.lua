local item_definitions = {}

item_definitions.definitions = {}

function item_definitions.initilize()
    local json_content = sys.load_resource("/resources/item_definitions.json")
    if json_content then
        item_definitions.definitions = json.decode(json_content)
    else
        print("Failed to load item_definitions JSON file")
    end
end

return item_definitions