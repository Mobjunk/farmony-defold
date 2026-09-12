local character_actions = {}

character_actions.SUFFIX = {
    walk = "",
    carry = "_carry",
    pickaxe = "_pickaxe",
    sword = "_sword",
    axe = "_axe",
    rod = "_rod",
    hoe = "_hoe",
    watering = "_watering",
}

character_actions.OFFSET = {
    pickaxe = { x = 0, y = 0, z = 0 },
    axe = { x = 0, y = 0, z = 0 },
    sword = { x = 0, y = 0, z = 0 },
    rod = { x = 0, y = -4, z = 0 },
    hoe = { x = 0, y = -7, z = 0, not_down = { x = 0, y = -1, z = 0 } },
    watering = { x = 0, y = -5, z = 0 },
}

function character_actions.suffix(action)
    return character_actions.SUFFIX[action] or ""
end

function character_actions.property(action)
    if not action or action == "walk" then
        return "default"
    end
    return action
end

function character_actions.fallback(action)
    return "default" .. character_actions.suffix(action)
end

function character_actions.offset(action, direction)
    local data = character_actions.OFFSET[action]
    if not data then
        return nil
    end
    if action == "hoe" and direction ~= "down" and data.not_down then
        return vmath.vector3(data.not_down.x, data.not_down.y, data.not_down.z)
    end
    return vmath.vector3(data.x, data.y, data.z)
end

return character_actions
