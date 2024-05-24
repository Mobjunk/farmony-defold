local character_info = require('modules.character.character_information')

local character_animation = {}

function character_animation.new()
	local instance = {
		current_animation = nil,
		animation_playing = false
	}

	function instance.reset_animation(url, default, no_debug)
		if not no_debug then
			print('reset_animation ' .. url)
		end
		go.set(url, "image", default)
		instance.animation_playing = false
	end

	function instance.play_animation(url, direction)
		--print('trying to animate: ',url)
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
		local input = false--direction ~= nil and direction.x ~= 0 or direction.y ~= 0
		if direction ~= nil then
			input = direction.x ~= 0 or direction.y ~= 0
		end

		if not input then
			if character_info.direction == 'right' then
				anim = animations["idle_right"][instance.get_color_index(url)]
			elseif character_info.direction == 'left' then
				anim = animations["idle_left"][instance.get_color_index(url)]
			elseif character_info.direction == 'up' then
				anim = animations["idle_up"][instance.get_color_index(url)]
			elseif character_info.direction == 'down' then
				anim = animations["idle_down"][instance.get_color_index(url)]
			end
		else
			if direction.x > 0 then
				anim = animations["walk_right"][instance.get_color_index(url)]
			elseif direction.x < 0 then
				anim = animations["walk_left"][instance.get_color_index(url)]
			elseif direction.y > 0 then
				anim = animations["walk_up"][instance.get_color_index(url)]
			elseif direction.y < 0 then
				anim = animations["walk_down"][instance.get_color_index(url)]
			end
		end

		if url == '#hair' then
			print('anim on '..url..'',anim)
		end
		if anim == instance.current_animation and input then
			return;
		end

		msg.post(url, "play_animation", { id = anim })
		instance.current_animation = anim
	end

	function instance.start_animation(url, animation)
		go.set(url, "image", animation)
		instance.play_animation(url)
		instance.animation_playing = true
	end

	function instance.on_message(message_id, url, default)
		if message_id == hash("animation_done") then
			instance.reset_animation(url, default, true)
		end
	end

	function instance.get_color_index(url)
		local color_indices = {
			["#hair"] = 6,
			["#eyes"] = 5,
			["#shoes"] = 4,
			["#pants"] = 3,
			["#shirt"] = 2
		}
	
		return color_indices[url] or 1
	end

	return instance
end

return character_animation
