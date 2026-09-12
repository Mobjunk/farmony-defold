local character_appearance = {}

character_appearance.LAYERS = {
    "shirt#character_shirt",
    "pants#character_pants",
    "shoes#character_shoes",
    "eyes#character_eyes",
    "hair#character_hair",
    "body#character_body",
}

character_appearance.ACTION_LAYERS = {
    "shirt#character_shirt",
    "pants#character_pants",
    "shoes#character_shoes",
    "eyes#character_eyes",
    "hair#character_hair",
    "body#character_body",
    "tool#character_tool",
}

function character_appearance.broadcast(urls, message_id, data)
    for i = 1, #urls do
        msg.post(urls[i], message_id, data)
    end
end

function character_appearance.reset(facing)
    character_appearance.broadcast(character_appearance.LAYERS, "reset_animation", { facing = facing })
end

function character_appearance.animate(direction, facing)
    character_appearance.broadcast(character_appearance.LAYERS, "animate", { direction = direction, facing = facing })
end

function character_appearance.play_action(action, facing)
    character_appearance.broadcast(character_appearance.ACTION_LAYERS, "animate_character", { action = action, facing = facing })
end

return character_appearance
