local character_info = require('modules.character.character_information')

local navigation = {}

navigation.switch_delay = 0
navigation.selected_node = ''

function navigation.set_selected(selected)
	navigation.selected_node = selected
	local position = gui.get_screen_position(gui.get_node(navigation.selected_node))
    local pivot = gui.get_pivot(gui.get_node(navigation.selected_node))
    local size = gui.get_size(gui.get_node(navigation.selected_node))
	local position = gui.get_screen_position(gui.get_node(navigation.selected_node))

    local offset = vmath.vector3(0, 0, 0)

    if pivot == gui.PIVOT_CENTER then
        offset = vmath.vector3(size.x, -size.y, 0)
    elseif pivot == gui.PIVOT_N then
        print('PIVOT_N')
    elseif pivot == gui.PIVOT_NW then
        offset = vmath.vector3(size.x * 2, -(size.y * 2), 0)
    end

	msg.post('virtual_mouse#virtual_mouse', 'set', { x = position.x + offset.x, y = position.y + offset.y })
end

function navigation.add_navigation_button(self, node_name, up_node, right_node, down_node, left_node, callback)
	click_callback = click_callback or nil
	self.navigation_buttons[node_name] = {
		up = up_node,
		right = right_node,
		down = down_node,
		left = left_node,
		callback = callback
	}
end

function navigation.navigate(self, direction)
	if self.navigation_buttons[navigation.selected_node] == nil then return end

	local next_node = self.navigation_buttons[navigation.selected_node][direction]
	if next_node == nil or navigation.switch_delay > 0 then return end

	navigation.selected_node = next_node

    local pivot = gui.get_pivot(gui.get_node(navigation.selected_node))
    local size = gui.get_size(gui.get_node(navigation.selected_node))
	local position = gui.get_screen_position(gui.get_node(navigation.selected_node))

    local offset = vmath.vector3(0, 0, 0)

    if pivot == gui.PIVOT_CENTER then
        offset = vmath.vector3(size.x, -size.y, 0)
    elseif pivot == gui.PIVOT_N then
        print('PIVOT_N')
    elseif pivot == gui.PIVOT_NW then
        offset = vmath.vector3(size.x * 2, -(size.y * 2), 0)
    end

	msg.post('virtual_mouse#virtual_mouse', 'set', { x = position.x + offset.x, y = position.y + offset.y })
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
		if self.navigation_buttons[navigation.selected_node] == nil then return end
		local callback = self.navigation_buttons[navigation.selected_node].callback
		if callback == nil then return end

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