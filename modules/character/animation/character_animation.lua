local character_animation = {}
local methods = {}

local LAYER_COLOR = {
    ["#body"] = "skin",
    ["#shirt"] = "shirt",
    ["#pants"] = "pants",
    ["#shoes"] = "shoes",
    ["#eyes"] = "eyes",
    ["#hair"] = "hair",
    ["#tool"] = "tool",
}

local function color_for(url, looks)
    if not looks then
        return 0
    end
    local layer = LAYER_COLOR[url]
    if layer == "shirt" then
        return looks.shirt.color
    elseif layer == "pants" then
        return looks.pants.color
    elseif layer == "hair" then
        return looks.hair.color
    elseif layer == "skin" then
        return looks.skin_color
    elseif layer == "shoes" then
        return looks.shoes_color
    elseif layer == "eyes" then
        return looks.eyes_color
    end
    return 0
end

local function facing_from_direction(direction, fallback)
    if direction.x > 0 then
        return "right"
    elseif direction.x < 0 then
        return "left"
    elseif direction.y > 0 then
        return "up"
    elseif direction.y < 0 then
        return "down"
    end
    return fallback or "down"
end

function methods.reset_animation(instance, url, tilesource)
    if tilesource then
        go.set(url, "image", tilesource)
    end
    instance.animation_playing = false
    instance.current_animation = nil
    instance.current_tilesource = tilesource
end

function methods.play_animation(instance, url, direction, state)
    state = state or instance.state
    local looks = state and state.looks
    local idle_facing = (state and state.direction) or instance.last_facing or "down"
    local moving = direction ~= nil and (direction.x ~= 0 or direction.y ~= 0)
    local anim_state
    local facing
    if moving then
        anim_state = "walk"
        facing = facing_from_direction(direction, idle_facing)
        instance.last_facing = facing
        if state then
            state.direction = facing
        end
    else
        anim_state = "idle"
        facing = idle_facing
        instance.last_facing = facing
    end

    local anim = hash(anim_state .. "_" .. facing .. "_" .. color_for(url, looks))
    if anim == instance.current_animation then
        return
    end

    msg.post(url, "play_animation", { id = anim })
    instance.current_animation = anim
end

function methods.start_animation(instance, url, tilesource, state)
    if tilesource then
        go.set(url, "image", tilesource)
        instance.current_tilesource = tilesource
    end
    instance.current_animation = nil
    methods.play_animation(instance, url, nil, state)
    instance.animation_playing = true
end

function methods.on_message(instance, message_id, url, default_tilesource, default_pos, state)
    if message_id == hash("animation_done") then
        if default_pos then
            go.set_position(default_pos)
        end
        methods.reset_animation(instance, url, default_tilesource)
        methods.play_animation(instance, url, nil, state)
    end
end

function character_animation.new()
    local instance = {
        current_animation = nil,
        current_tilesource = nil,
        animation_playing = false,
        last_facing = "down",
        state = nil,
    }

    function instance.reset_animation(url, tilesource)
        methods.reset_animation(instance, url, tilesource)
    end

    function instance.play_animation(url, direction, state)
        methods.play_animation(instance, url, direction, state)
    end

    function instance.start_animation(url, tilesource, state)
        methods.start_animation(instance, url, tilesource, state)
    end

    function instance.on_message(message_id, url, default_tilesource, default_pos, state)
        methods.on_message(instance, message_id, url, default_tilesource, default_pos, state)
    end

    return instance
end

return character_animation
