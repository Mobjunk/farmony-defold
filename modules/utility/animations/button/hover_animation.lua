local hover_animation = {}


function hover_animation.new()

	local instance = {
        hover_animations = {},
		is_hovering = false,
		callback = nil
    }

	function instance.init(callback)
		instance.callback = callback
	end
	
	function instance.on_click(animated_node)
		animated_node['callback']()
	end
	
	function instance.on_hover(animated_node)
		gui.set_scale(gui.get_node(animated_node['node']), animated_node['hover_scale'])
	end
	
	function instance.on_hover_exit(animated_node)
		gui.set_scale(gui.get_node(animated_node['node']), animated_node['default_scale'])
	end
	
	function instance.update(dt, node)
		
	end

	return instance

end

return hover_animation