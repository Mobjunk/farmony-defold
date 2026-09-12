local character_controller = {}

local MOVE = {
    [hash("up")] = { y = 1, dir = "up", controller = false },
    [hash("down")] = { y = -1, dir = "down", controller = false },
    [hash("left")] = { x = -1, dir = "left", controller = false },
    [hash("right")] = { x = 1, dir = "right", controller = false },
    [hash("up_controller")] = { y = 1, dir = "up", controller = true },
    [hash("down_controller")] = { y = -1, dir = "down", controller = true },
    [hash("left_controller")] = { x = -1, dir = "left", controller = true },
    [hash("right_controller")] = { x = 1, dir = "right", controller = true },
}

function character_controller.handle_input(self, action_id, action, animation_playing, state)
    if (action_id == hash("gamepad_connected") or action_id == hash("gamepad_disconnected")) and action.gamepad == 0 then
        state.controller_connected = action_id == hash("gamepad_connected")
        return
    end

    local move = MOVE[action_id]
    if move and not animation_playing and state.can_move then
        local analog_ok = true
        if move.controller then
            analog_ok = action.value ~= nil and action.value > state.controller_deadzone
        end
        if analog_ok then
            state.direction = move.dir
            state.using_controller_settings = move.controller
            if move.x then
                self.dir.x = move.x
            end
            if move.y then
                self.dir.y = move.y
            end
        end
    end

    if not action.released then
        return
    end

    if action_id == hash("perform_action") or action_id == hash("perform_action_controller") then
        state.using_controller_settings = action_id == hash("perform_action_controller")
        return { perform_action = true }
    elseif action_id == hash("inventory") or action_id == hash("inventory_controller") then
        state.using_controller_settings = action_id == hash("inventory_controller")
        return { toggle_inventory = true }
    elseif action_id == hash("randomize") then
        return { toggle_design = true }
    end
end

return character_controller
