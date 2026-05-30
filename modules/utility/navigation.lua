local character_info = require('modules.character.character_information')

local navigation = {}

navigation.switch_delay = 0
navigation.selected_node = ''
navigation.overrides = {}

local DIRECTION_MIN_DELTA = 2
local ALIGNMENT_WEIGHT = 2

local function get_virtual_mouse_offset(node)
	local pivot = gui.get_pivot(node)
	local size = gui.get_size(node)

	if pivot == gui.PIVOT_CENTER then
		return vmath.vector3(size.x, -size.y, 0)
	elseif pivot == gui.PIVOT_NW then
		return vmath.vector3(size.x * 2, -(size.y * 2), 0)
	end

	return vmath.vector3(0, 0, 0)
end

local function get_screen_center(node_name)
	local node = gui.get_node(node_name)
	local position = gui.get_screen_position(node)
	local size = gui.get_size(node)
	local scale = gui.get_scale(node)
	local pivot = gui.get_pivot(node)
	local center_offset = vmath.vector3(0, 0, 0)

	if pivot == gui.PIVOT_NW then
		center_offset = vmath.vector3(size.x * scale.x * 0.5, -(size.y * scale.y * 0.5), 0)
	elseif pivot == gui.PIVOT_N then
		center_offset = vmath.vector3(size.x * scale.x * 0.5, -(size.y * scale.y), 0)
	end

	return vmath.vector3(position.x + center_offset.x, position.y + center_offset.y, 0)
end

local function move_virtual_mouse_to_node(node_name)
	local node = gui.get_node(node_name)
	local position = gui.get_screen_position(node)
	local offset = get_virtual_mouse_offset(node)
	msg.post('virtual_mouse#virtual_mouse', 'set', {
		x = position.x + offset.x,
		y = position.y + offset.y
	})
end

local function direction_score(direction, from_center, to_center)
	local dx = to_center.x - from_center.x
	local dy = to_center.y - from_center.y

	if direction == 'right' then
		if dx < DIRECTION_MIN_DELTA then
			return nil
		end
		return dx + math.abs(dy) * ALIGNMENT_WEIGHT
	elseif direction == 'left' then
		if dx > -DIRECTION_MIN_DELTA then
			return nil
		end
		return -dx + math.abs(dy) * ALIGNMENT_WEIGHT
	elseif direction == 'up' then
		if dy < DIRECTION_MIN_DELTA then
			return nil
		end
		return dy + math.abs(dx) * ALIGNMENT_WEIGHT
	elseif direction == 'down' then
		if dy > -DIRECTION_MIN_DELTA then
			return nil
		end
		return -dy + math.abs(dx) * ALIGNMENT_WEIGHT
	end

	return nil
end

function navigation.find_spatial_neighbor(self, from_node_name, direction)
	local from_center = get_screen_center(from_node_name)
	local best_node = nil
	local best_score = math.huge

	for node_name, _ in pairs(self.navigation_buttons) do
		if node_name ~= from_node_name then
			local score = direction_score(direction, from_center, get_screen_center(node_name))
			if score and score < best_score then
				best_score = score
				best_node = node_name
			end
		end
	end

	return best_node
end

function navigation.set_override(node_name, direction, target_node)
	if navigation.overrides[node_name] == nil then
		navigation.overrides[node_name] = {}
	end
	navigation.overrides[node_name][direction] = target_node
end

function navigation.set_selected(selected)
	navigation.selected_node = selected
	move_virtual_mouse_to_node(navigation.selected_node)
end

function navigation.add_navigation_button(self, node_name, up_node, right_node, down_node, left_node, callback)
	self.navigation_buttons[node_name] = {
		up = up_node,
		right = right_node,
		down = down_node,
		left = left_node,
		callback = callback,
		spatial = false
	}
end

function navigation.add_focusable(self, node_name, callback)
	self.navigation_buttons[node_name] = {
		callback = callback,
		spatial = true
	}
end

function navigation.resolve_neighbor(self, from_node_name, direction)
	local overrides = navigation.overrides[from_node_name]
	if overrides and overrides[direction] then
		return overrides[direction]
	end

	local button = self.navigation_buttons[from_node_name]
	if button == nil then
		return nil
	end

	if button.spatial then
		return navigation.find_spatial_neighbor(self, from_node_name, direction)
	end

	return button[direction]
end

function navigation.navigate(self, direction)
	if self.navigation_buttons[navigation.selected_node] == nil then
		return
	end
	if navigation.switch_delay > 0 then
		return
	end

	local next_node = navigation.resolve_neighbor(self, navigation.selected_node, direction)
	if next_node == nil then
		return
	end

	navigation.selected_node = next_node
	move_virtual_mouse_to_node(navigation.selected_node)
	navigation.switch_delay = 0.2
	character_info.using_controller_settings = true
end

function navigation.update(dt)
	if navigation.switch_delay > 0 then
		navigation.switch_delay = navigation.switch_delay - dt
	end
end

function navigation.handle_navigation(self, action_id, action)
	if action_id == hash("interact_controller") and action.released then
		if self.navigation_buttons[navigation.selected_node] == nil then
			return
		end
		local callback = self.navigation_buttons[navigation.selected_node].callback
		if callback == nil then
			return
		end

		callback()
		character_info.using_controller_settings = true
	end

	if action_id == hash("down_controller") and action.value > character_info.controller_deadzone then
		navigation.navigate(self, 'down')
	elseif action_id == hash("up_controller") and action.value > character_info.controller_deadzone then
		navigation.navigate(self, 'up')
	elseif action_id == hash("left_controller") and action.value > character_info.controller_deadzone then
		navigation.navigate(self, 'left')
	elseif action_id == hash("right_controller") and action.value > character_info.controller_deadzone then
		navigation.navigate(self, 'right')
	end
end

return navigation
