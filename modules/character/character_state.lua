local character_looks = require("modules.character.character_looks")

local character_state = {}

function character_state.new()
    return {
        is_player = false,
        controller_deadzone = 0.33,
        controller_connected = false,
        using_controller_settings = false,
        is_hovering_gui = false,
        can_move = true,
        is_carrying = false,
        carry_item_id = 0,
        direction = "down",
        looks = character_looks.new(),
    }
end

return character_state
