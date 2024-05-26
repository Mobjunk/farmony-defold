---@class spin_animation_instance
---@field is_hovering boolean

local spin_animation_module = require('modules.utility.animations.spin.spin_animation')
local hover_animation_module = require('modules.utility.animations.button.hover_animation')

---@return table The new animation manager instance.
local animations = {}

--- Creates a new instance of the animation manager.
function animations.new()
    local instance = {
        animated_nodes = {}
    }

    --- Creates a new button with hover animation.
    ---@param node string The GUI nodes name for the button.
    ---@param callback function The callback function to be triggered on click (optional).
    ---@param default_scale vector3 The default scale of the button (optional).
    ---@param hover_scale vector3 The hover scale of the button (optional).
    function instance.new_button(node, callback, default_scale, hover_scale)
        default_scale = default_scale or vmath.vector3(1, 1, 1)
        hover_scale = hover_scale or vmath.vector3(1.01, 1.01, 1.01)
        callback = callback or nil
        instance.animated_nodes[#instance.animated_nodes + 1] = { node = node, module = hover_animation_module.new(), callback = callback, default_scale = default_scale, hover_scale = hover_scale }
    end

    --- Creates a new spinning GUI animation.
    ---@param node userdata The GUI node to apply spinning animation.
    ---@param callback function The callback function to be triggered on click (optional).
    ---@param speed number The spinning speed (optional).
    ---@param timer number The spinning timer (optional).
    function instance.new_spinning_gui(node, callback, speed, timer)
        speed = speed or 12
        timer = timer or 0.5
        callback = callback or nil
        instance.animated_nodes[#instance.animated_nodes + 1] = { node = node, module = spin_animation_module.new(), callback = callback, speed = speed, timer = timer }
    end

    --- Handles input events for animated nodes.
    ---@param action_id hash The action ID.
    ---@param action table The action table.
    function instance.on_input(action_id, action)
        for _, animated_node in pairs(instance.animated_nodes) do
            local node = gui.get_node(animated_node.node)
            local module = animated_node.module
            if gui.pick_node(node, action.x, action.y) and gui.is_enabled(node, false) then
                if not module.is_hovering then
                    module.on_hover(animated_node)
                    module.is_hovering = true
                end
                if action_id == hash("touch") and action.pressed then
                    module.on_click(animated_node)
                end
            else
                if module.is_hovering then
                    module.on_hover_exit(animated_node)
                    module.is_hovering = false
                end
            end
        end
    end

    --- Updates the animation manager.
    ---@param dt number The elapsed time since the last update.
    function instance.update(dt)
        for _, animated_node in pairs(instance.animated_nodes) do
            animated_node.module.update(dt, animated_node)
        end
    end

    return instance
end

return animations
