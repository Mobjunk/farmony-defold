local spin_animation = {}

function spin_animation.new()
	local instance = {
		is_hovering = false,
		spin = false,
		global_timer = 0
    }

	function instance.on_click(animated_node)
		instance.spin = true
		if animated_node['callback'] ~= nil then
			animated_node['callback']()
			print("test")
		end
	end
	
	function instance.update(dt, animated_node)
		if instance.spin then
			
			instance.global_timer = instance.global_timer + dt
			if instance.global_timer < animated_node['timer'] then
				local step = math.floor(instance.global_timer * animated_node['speed'])
				local angle = math.pi / 6 * step
				local rotation = vmath.quat_rotation_z(-angle)
				gui.set_rotation(gui.get_node(animated_node['node']), rotation)
			else
				instance.global_timer = 0
				instance.spin = false
				print("test stop")
			end
		end
	end
	
	function instance.on_hover(animated_node)
	end
	
	function instance.on_hover_exit(animated_node)
	end

	return instance
end

return spin_animation