local character_registry = require("modules.character.character_registry")
local character_looks = require("modules.character.character_looks")
local character_actions = require("modules.character.character_actions")
local character_animation_module = require("modules.character.animation.character_animation")

local character_layer = {}

local function current_idle_action(state)
    if state and state.is_carrying then
        return "carry"
    end
    return "walk"
end

local function tilesource_for(self, config, state, action)
    action = action or current_idle_action(state)
    local looks = state and state.looks
    local property
    if config.style_kind and looks then
        local style_data = looks[config.style_kind]
        local base = character_looks.property_name(style_data and style_data.style)
        property = base .. character_actions.suffix(action)
    else
        property = character_actions.property(action)
    end
    return self[property] or self[character_actions.fallback(action)] or self.default
end

function character_layer.create(config)
    local animation = character_animation_module.new()
    local default_pos
    local layer = {}

    local function state()
        return character_registry.parent()
    end

    local function apply_facing(current, facing)
        if facing and current then
            current.direction = facing
        end
        return current
    end

    function layer.init(self)
        default_pos = go.get_position()
        local current = state()
        local tilesource = tilesource_for(self, config, current, current_idle_action(current))
        if tilesource then
            animation.reset_animation(config.sprite_url, tilesource)
            animation.play_animation(config.sprite_url, nil, current)
        end
    end

    function layer.on_message(self, message_id, message)
        message = message or {}
        local current = apply_facing(state(), message.facing)
        if message_id == hash("reset_animation") then
            animation.reset_animation(config.sprite_url, tilesource_for(self, config, current))
            animation.play_animation(config.sprite_url, nil, current)
        elseif message_id == hash("animate") then
            animation.play_animation(config.sprite_url, message.direction, current)
        elseif message_id == hash("animate_character") then
            local action = message.action
            if not action then
                return
            end
            local tilesource = tilesource_for(self, config, current, action)
            if not tilesource then
                return
            end
            animation.start_animation(config.sprite_url, tilesource, current)
            local direction = (current and current.direction) or message.facing or "down"
            local offset = character_actions.offset(action, direction)
            if offset then
                go.set_position(offset)
            end
        end

        animation.on_message(message_id, config.sprite_url, tilesource_for(self, config, current), default_pos, current)
    end

    return layer
end

return character_layer
