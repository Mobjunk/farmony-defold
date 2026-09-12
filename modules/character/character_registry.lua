local character_registry = {}

local states = {}
local player_id

function character_registry.register(id, state)
    states[id] = state
    if state.is_player then
        player_id = id
    end
end

function character_registry.unregister(id)
    if player_id == id then
        player_id = nil
    end
    states[id] = nil
end

function character_registry.get(id)
    return states[id]
end

function character_registry.mine()
    return states[go.get_id()]
end

function character_registry.parent()
    local parent_id = go.get_parent()
    if parent_id then
        return states[parent_id]
    end
end

function character_registry.player()
    if player_id then
        return states[player_id]
    end
end

return character_registry
