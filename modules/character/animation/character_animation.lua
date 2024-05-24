local character_info = require('modules.character.character_information')

local character_animation = {}

character_animation.current_animation = nil
character_animation.animation_playing = false

function character_animation.reset_animation(url, default, no_debug)
	if not no_debug then
		print('reset_animation ' .. url)
	end
    go.set(url, "image", default)
	character_animation.animation_playing = false
end

function character_animation.play_animation(url)
	local directions = {
		"walk_right", "walk_left", "walk_up", "walk_down",
		"idle_right", "idle_left", "idle_up", "idle_down"
	}
	local animations = {}
	
	for _, direction in ipairs(directions) do
		animations[direction] = {}
		for _, color in ipairs(character_info.looks.colors) do
			table.insert(animations[direction], hash(direction .. "_" .. color))
		end
	end
	
	local anim = animations["idle_" .. character_info.direction][1]
	local input = character_info.walking_dir.x ~= 0 or character_info.walking_dir.y ~= 0

	if not input then
		if character_info.walking_dir.x > 0 then
			anim = animations["idle_right"][1]
		elseif character_info.walking_dir.x < 0 then
			anim = animations["idle_left"][1]
		elseif character_info.walking_dir.y > 0 then
			anim = animations["idle_up"][1]
		elseif character_info.walking_dir.y < 0 then
			anim = animations["idle_down"][1]
		end
	else
		if character_info.walking_dir.x > 0 then
			anim = animations["walk_right"][1]
		elseif character_info.walking_dir.x < 0 then
			anim = animations["walk_left"][1]
		elseif character_info.walking_dir.y > 0 then
			anim = animations["walk_up"][1]
		elseif character_info.walking_dir.y < 0 then
			anim = animations["walk_down"][1]
		end
	end

	if anim == character_animation.current_animation and input then
		return;
	end

	msg.post(url, "play_animation", { id = anim })
	character_animation.current_animation = anim
end

function character_animation.start_animation(url, animation)
    go.set(url, "image", animation)
	character_animation.play_animation(url)
	character_animation.animation_playing = true
end

function character_animation.on_message(message_id, url, default)
	if message_id == hash("animation_done") then
		character_animation.reset_animation(url, default)
	end
end

return character_animation
