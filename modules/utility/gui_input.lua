local character_info = require("modules.character.character_information")
local navigation = require("modules.utility.navigation")

local gui_input = {}

local MOUSE_CLICK = {
	[hash("touch")] = true,
	[hash("perform_action")] = true,
}

local function is_controller_action(action_id)
	return action_id == hash("interact_controller")
		or action_id == hash("down_controller")
		or action_id == hash("up_controller")
		or action_id == hash("left_controller")
		or action_id == hash("right_controller")
end

local function is_mouse_move(action_id, action)
	return action_id == nil and action ~= nil and ((action.dx or 0) ~= 0 or (action.dy or 0) ~= 0)
end

local function is_mouse_button(action_id)
	return action_id ~= nil and MOUSE_CLICK[action_id]
end

local function is_mouse_click(action_id, action)
	return is_mouse_button(action_id) and action.released
end

local function use_mouse()
	character_info.using_controller_settings = false
	msg.post("virtual_mouse#virtual_mouse", "reset")
end

local function handle_mouse(self, action_id, action)
	if not is_mouse_click(action_id, action) then
		return
	end
	if action.x == nil or action.y == nil then
		return
	end

	for node_name, button in pairs(self.navigation_buttons) do
		if gui.pick_node(gui.get_node(node_name), action.x, action.y) then
			if button.callback then
				button.callback()
			end
			return
		end
	end
end

function gui_input.is_mouse_click(action_id, action)
	return is_mouse_click(action_id, action)
end

function gui_input.handle(self, action_id, action)
	if is_controller_action(action_id) then
		character_info.using_controller_settings = true
	elseif is_mouse_button(action_id) or is_mouse_move(action_id, action) then
		use_mouse()
	end

	if character_info.using_controller_settings then
		navigation.handle_navigation(self, action_id, action)
	else
		handle_mouse(self, action_id, action)
	end
end

return gui_input
