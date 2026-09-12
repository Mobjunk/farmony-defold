local character_looks = {}

character_looks.HAIR_STYLES = { "buzzcut", "braids", "curly", "emo", "extralong", "frenchcurl", "gentleman", "midiwave", "spacebuns", "wavy" }
character_looks.SHIRT_STYLES = { "basic", "floral", "overall", "sailor", "sailor_bow", "sporty", "suit" }
character_looks.PANTS_STYLES = { "pants", "pants_suit", "skirt" }
character_looks.DIRECTIONS = { "down", "right", "up", "left" }

character_looks.PROPERTY_NAME = {
    buzzcut = "default",
    basic = "default",
    pants = "default",
    pants_suit = "suit",
}

character_looks.COLOR_MAX = {
    skin = 7,
    hair = 9,
    shirt = 9,
    pants = 9,
    eyes = 9,
    shoes = 9,
}

local function wrap_index(index, count)
    if index < 1 then
        return count
    elseif index > count then
        return 1
    end
    return index
end

local function cycle_list(list, current, delta)
    local index = 1
    for i, name in ipairs(list) do
        if name == current then
            index = i
            break
        end
    end
    return list[wrap_index(index + delta, #list)]
end

local function cycle_color(current, max_value, delta)
    local value = current + delta
    if value < 0 then
        return max_value
    elseif value > max_value then
        return 0
    end
    return value
end

function character_looks.new()
    return {
        skin_color = 0,
        eyes_color = 0,
        shoes_color = 0,
        hair = { style = "buzzcut", color = 2 },
        shirt = { style = "basic", color = 0 },
        pants = { style = "pants", color = 0 },
    }
end

function character_looks.property_name(style)
    return character_looks.PROPERTY_NAME[style] or style
end

function character_looks.clamp_constraints(looks)
    if looks.shirt.style == "sailor_bow" and looks.shirt.color > 8 then
        looks.shirt.color = 8
    end
end

function character_looks.snapshot(looks)
    return {
        skin_color = looks.skin_color,
        eyes_color = looks.eyes_color,
        shoes_color = looks.shoes_color,
        hair = { style = looks.hair.style, color = looks.hair.color },
        shirt = { style = looks.shirt.style, color = looks.shirt.color },
        pants = { style = looks.pants.style, color = looks.pants.color },
    }
end

function character_looks.apply(looks, data)
    if not looks or not data then
        return
    end
    if data.skin_color ~= nil then
        looks.skin_color = data.skin_color
    end
    if data.eyes_color ~= nil then
        looks.eyes_color = data.eyes_color
    end
    if data.shoes_color ~= nil then
        looks.shoes_color = data.shoes_color
    end
    if data.hair then
        if data.hair.style ~= nil then
            looks.hair.style = data.hair.style
        end
        if data.hair.color ~= nil then
            looks.hair.color = data.hair.color
        end
    end
    if data.shirt then
        if data.shirt.style ~= nil then
            looks.shirt.style = data.shirt.style
        end
        if data.shirt.color ~= nil then
            looks.shirt.color = data.shirt.color
        end
    end
    if data.pants then
        if data.pants.style ~= nil then
            looks.pants.style = data.pants.style
        end
        if data.pants.color ~= nil then
            looks.pants.color = data.pants.color
        end
    end
    character_looks.clamp_constraints(looks)
end

function character_looks.randomize(looks)
    looks.skin_color = math.random(0, character_looks.COLOR_MAX.skin)
    looks.eyes_color = math.random(0, character_looks.COLOR_MAX.eyes)
    looks.shoes_color = math.random(0, character_looks.COLOR_MAX.shoes)
    looks.hair.style = character_looks.HAIR_STYLES[math.random(1, #character_looks.HAIR_STYLES)]
    looks.hair.color = math.random(0, character_looks.COLOR_MAX.hair)
    looks.shirt.style = character_looks.SHIRT_STYLES[math.random(1, #character_looks.SHIRT_STYLES)]
    looks.shirt.color = math.random(0, character_looks.COLOR_MAX.shirt)
    looks.pants.style = character_looks.PANTS_STYLES[math.random(1, #character_looks.PANTS_STYLES)]
    looks.pants.color = math.random(0, character_looks.COLOR_MAX.pants)
    character_looks.clamp_constraints(looks)
end

function character_looks.cycle_hair_style(looks, delta)
    looks.hair.style = cycle_list(character_looks.HAIR_STYLES, looks.hair.style, delta)
end

function character_looks.cycle_shirt_style(looks, delta)
    looks.shirt.style = cycle_list(character_looks.SHIRT_STYLES, looks.shirt.style, delta)
    character_looks.clamp_constraints(looks)
end

function character_looks.cycle_pants_style(looks, delta)
    looks.pants.style = cycle_list(character_looks.PANTS_STYLES, looks.pants.style, delta)
end

function character_looks.cycle_skin_color(looks, delta)
    looks.skin_color = cycle_color(looks.skin_color, character_looks.COLOR_MAX.skin, delta)
end

function character_looks.cycle_hair_color(looks, delta)
    looks.hair.color = cycle_color(looks.hair.color, character_looks.COLOR_MAX.hair, delta)
end

function character_looks.cycle_shirt_color(looks, delta)
    looks.shirt.color = cycle_color(looks.shirt.color, character_looks.COLOR_MAX.shirt, delta)
    character_looks.clamp_constraints(looks)
end

function character_looks.cycle_pants_color(looks, delta)
    looks.pants.color = cycle_color(looks.pants.color, character_looks.COLOR_MAX.pants, delta)
end

function character_looks.cycle_eyes_color(looks, delta)
    looks.eyes_color = cycle_color(looks.eyes_color, character_looks.COLOR_MAX.eyes, delta)
end

function character_looks.cycle_shoes_color(looks, delta)
    looks.shoes_color = cycle_color(looks.shoes_color, character_looks.COLOR_MAX.shoes, delta)
end

return character_looks
