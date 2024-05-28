---@diagnostic disable: missing-parameter

local item_snapper = require('modules.utility.item_snapper')
local character_info = require('modules.character.character_information')
local auto_layout = require('modules.utility.auto_layout')

local inventory = {}

inventory.grid_width = 12
inventory.grid_height = 3
inventory.total_slots = inventory.grid_width * inventory.grid_height

function inventory.handle_interaction(self)
    if not self.within_tabs then
        local position = gui.get_screen_position(gui.get_node('slot_' .. self.selected_slot .. '_icon'))
        if item_snapper.selected_item == nil then
            msg.post('character#character_inventory', 'item_snap', { slot = self.selected_slot, x = position.x + 25, y = position.y - 25 })
            character_info.using_controller_settings = true
            return true
        else
            msg.post('character#character_inventory', 'item_swap', { slot = self.selected_slot, x = position.x + 25, y = position.y - 25 })
            msg.post('character#character_inventory', "hovering_item", { slot = self.selected_slot, mouse_x = position.x, mouse_y = position.y })
            character_info.using_controller_settings = true
            return true
        end
    else
        inventory.handle_tab_switch(self, self.content[self.selected_tab])
		character_info.using_controller_settings = true
        return true
    end
end

function inventory.handle_tab_switch(self, tab_to_open)
	gui.set_enabled(self.opened_tab, false)
	self.opened_tab = tab_to_open
	gui.set_enabled(self.opened_tab, true)
end

function inventory.handle_controller_down(self)
    if self.switch_delay > 0 then return false end
	
    if self.within_tabs then
        if self.opened_tab == self.inventory_content then
            self.selected_slot = 1
            local position = inventory.set_virtual_mouse_position(gui.get_node('slot_' .. self.selected_slot .. '_icon'), 23, -23)
            inventory.hover_item(self.selected_slot, position)
            self.switch_delay = 0.2
            self.within_tabs = false
            character_info.using_controller_settings = true
            return true
        end
    elseif self.selected_slot <= inventory.total_slots - inventory.grid_width then
        inventory.switch_slot(self, self.selected_slot + inventory.grid_width)
		character_info.using_controller_settings = true
        return true
    end

    return false
end

function inventory.handle_controller_up(self)
    if self.switch_delay > 0 then return end
	
    if not self.within_tabs then
        if self.selected_slot > inventory.grid_width then
            inventory.switch_slot(self, self.selected_slot - inventory.grid_width)
            character_info.using_controller_settings = true
            return true
        elseif item_snapper.selected_item == nil then
            inventory.switch_to_tab(self, 1)
            character_info.using_controller_settings = true
            return true
        end
    end
    return false
end

function inventory.handle_controller_left(self)
    if self.switch_delay > 0 then return end
	
    if self.within_tabs then
        if self.selected_tab > 1 then
            inventory.switch_to_tab(self, self.selected_tab - 1)
            character_info.using_controller_settings = true
            return true
        end
    elseif (self.selected_slot - 1) % inventory.grid_width ~= 0 then
        inventory.switch_slot(self, self.selected_slot - 1)
        character_info.using_controller_settings = true
        return true
    end
    return false
end

function inventory.handle_controller_right(self)
    if self.switch_delay > 0 then return end
	
    if self.within_tabs then
        if self.selected_tab < #self.tabs then
            inventory.switch_to_tab(self, self.selected_tab + 1)
            character_info.using_controller_settings = true
            return true
        end
    elseif self.selected_slot % inventory.grid_width ~= 0 then
        inventory.switch_slot(self, self.selected_slot + 1)
        character_info.using_controller_settings = true
        return true
    end
    return false
end

function inventory.set_virtual_mouse_position(node, x_offset, y_offset)
    local position = gui.get_screen_position(node)
    msg.post('virtual_mouse#virtual_mouse', 'set', { x = position.x + x_offset, y = position.y + y_offset })
    return position
end

function inventory.hover_item(slot, position)
    msg.post('character#character_inventory', "hovering_item", { slot = slot, mouse_x = position.x, mouse_y = position.y })
end

function inventory.switch_slot(self, new_slot)
    self.selected_slot = new_slot
    local position = inventory.set_virtual_mouse_position(gui.get_node('slot_' .. new_slot .. '_icon'), 23, -23)
    inventory.hover_item(new_slot, position)
    self.switch_delay = 0.2
end

function inventory.switch_to_tab(self, tab_index)
    self.selected_tab = tab_index
    inventory.set_virtual_mouse_position(self.tabs[tab_index], 23, -23)
    self.switch_delay = 0.2
    self.within_tabs = true
    msg.post('tooltip_gui#tooltip', 'reset_tooltip')
end

function inventory.setup_grid(self)
    local slots = {}

	for index = 1, inventory.total_slots, 1 do
		local name_prefix = 'slot_' .. index .. '_'
		local prefab_clone = gui.clone_tree(gui.get_node('slot_prefab'))

		local slot_name = name_prefix .. 'slot'
		local highlight_name = name_prefix .. 'highlight'
		local icon_name = name_prefix .. 'icon'
		local optional_name = name_prefix .. 'optional'
		local amount_name = name_prefix .. 'amount'
		local durability_name = name_prefix .. 'durability'
		local durability_amount_name = name_prefix .. 'durability_amount'
		
        gui.set_id(prefab_clone["slot_prefab"], slot_name)
        gui.set_id(prefab_clone["slot_highlight"], highlight_name)
        gui.set_id(prefab_clone["slot_icon"], icon_name)
        gui.set_id(prefab_clone["slot_icon_optional"], optional_name)
        gui.set_id(prefab_clone["slot_amount"], amount_name)
        gui.set_id(prefab_clone["slot_durability"], durability_name)
        gui.set_id(prefab_clone["slot_durability_amount"], durability_amount_name)
	
        gui.set_parent(gui.get_node(slot_name), self.inventory_content)

		slots[#slots + 1] = slot_name
	end

	auto_layout.setup_grid('inventory_content', slots, vmath.vector3(32, 32, 1), 12, 0)
end

function inventory.handle_mouse_movement(action_id, action)
    if not character_info.using_controller_settings then
		local is_hovering = false

		for slot = 1, inventory.total_slots, 1 do
			if gui.pick_node(gui.get_node('slot_' .. slot .. '_icon'), action.x, action.y) then
				is_hovering = true
				character_info.is_hovering_gui = true
				msg.post('character#character_inventory', "hovering_item", { slot = slot, mouse_x = action.x, mouse_y = action.y })
				if action_id == hash('touch') and action.released then
					if item_snapper.selected_item == nil then
						msg.post('character#character_inventory', 'item_snap', { slot = slot, x = action.x, y = action.y })
					else
						msg.post('character#character_inventory', 'item_swap', { slot = slot, x = action.x, y = action.y })
					end
				end
			end
		end

		if not is_hovering then
			character_info.is_hovering_gui = false
			msg.post('tooltip_gui#tooltip', 'reset_tooltip')
		end
	end
end

return inventory