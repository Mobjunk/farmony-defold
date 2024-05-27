---@class auto_layout
local auto_layout = {}

---Handles setting up a panel with the correct sizing for all the children within the panel
---@param panel_prefix string The prefix of the panel that is used for grabbing all the required nodes
---@param panel_width number The width of the main panel
---@param panel_height number The height of the main panel
---@param horizontal_padding number The horizontal padding between the panel and the content
---@param vertical_padding number The vertical padding between the panel and the content
---@param outline_offset number The amount of pixels of offset is required for the panel
---@param file_path string The path to a file, this is used when you want to scene view to match the game view
function auto_layout.setup_panel(panel_prefix, panel_width, panel_height, horizontal_padding, vertical_padding, outline_offset, file_path)
    local panel_shadow = gui.get_node(panel_prefix .. '_shadow')
    local panel_background = gui.get_node(panel_prefix .. '_background')
    local panel_outline = gui.get_node(panel_prefix .. '_outline')
    local panel_layout = gui.get_node(panel_prefix .. '_layout')
    local panel_content = gui.get_node(panel_prefix .. '_content')
    gui.set_size(panel_shadow, vmath.vector3(panel_width, panel_height, 1))
    gui.set_size(panel_background, vmath.vector3(panel_width, panel_height, 1))
    gui.set_size(panel_outline, vmath.vector3(panel_width + outline_offset, panel_height + outline_offset, 1))
    gui.set_size(panel_layout, vmath.vector3(panel_width - (horizontal_padding * 2), panel_height - (vertical_padding * 2), 1))
    gui.set_size(panel_content, gui.get_size(panel_layout))
    gui.set_position(panel_content, vmath.vector3(0, gui.get_size(panel_layout).y / 2, 0))

    if file_path then
        auto_layout.read_content(file_path, panel_prefix .. '_shadow', panel_width, panel_height, 'size')
        auto_layout.read_content(file_path, panel_prefix .. '_background', panel_width, panel_height, 'size')
        auto_layout.read_content(file_path, panel_prefix .. '_outline', panel_width + outline_offset, panel_height + outline_offset, 'size')
        auto_layout.read_content(file_path, panel_prefix .. '_layout', panel_width - (horizontal_padding * 2), panel_height - (vertical_padding * 2), 'size')
        auto_layout.read_content(file_path, panel_prefix .. '_content', panel_width - (horizontal_padding * 2), panel_height - (vertical_padding * 2), 'size')
        auto_layout.read_content(file_path, panel_prefix .. '_content', 0, gui.get_size(panel_layout).y / 2, 'position')
    end 
end

function auto_layout.setup_content(panel_prefix, panel_width, panel_height, horizontal_padding, vertical_padding)
    local panel = gui.get_node(panel_prefix)
    local panel_content = gui.get_node(panel_prefix .. '_content')
    gui.set_size(panel, vmath.vector3(panel_width, panel_height, 1))
    gui.set_size(panel_content, vmath.vector3(panel_width - (horizontal_padding * 2), panel_height - (vertical_padding * 2), 1))
    gui.set_position(panel_content, vmath.vector3(0, -vertical_padding, 0))
end

---Getting the largest child within the parent
---@param layout string The layout group ('vertical' or 'horizontal')
---@param children table The children to check
---@return number
function auto_layout.get_largest_child_size(layout, children)
    local largest_size = 0
    for _, child in ipairs(children) do
        local size = gui.get_size(gui.get_node(child))
        if (layout == "vertical" and size.x > largest_size) or
           (layout == "horizontal" and size.y > largest_size) then
            largest_size = (layout == "vertical") and size.x or size.y
        end
    end
    return largest_size
end

---Setting up the auto layout of a node with its children
---@param layout string The layout of the parent ('vertical' or 'horizontal')
---@param children table The children within the parent
---@param padding number The amount of padding between the children
---@param parent_name string The name of the parent node, (optional, keep it empty if there is no parent to resize)
---@param file_path string The path to a file, this is used when you want to scene view to match the game view
function auto_layout.setup_layout(layout, children, padding, parent_name, file_path)
    parent_name = parent_name or ''
    local parent = nil
    if parent_name ~= '' then
        parent = gui.get_node(parent_name)
    end
    local total_size = vmath.vector3(0, 0, 0)

    for index, child in ipairs(children) do
        if index > 1 then
            local node = gui.get_node(child)
            local previous_child = gui.get_node(children[index - 1])
            local previous_size = gui.get_size(previous_child)
            local previous_scale = gui.get_scale(previous_child)
            local previous_position = gui.get_position(previous_child)

            local position, increment
            if layout == "vertical" then
                increment = previous_size.y * previous_scale.y + padding
                position = vmath.vector3(previous_position.x, -(math.abs(gui.get_position(previous_child).y) + increment), 0)
                total_size.y = total_size.y + increment
            elseif layout == "horizontal" then
                increment = previous_size.x * previous_scale.x + padding
                position = vmath.vector3(math.abs(gui.get_position(previous_child).x) + increment, previous_position.y, 0)
                total_size.x = total_size.x + increment
            end

            gui.set_position(node, position)

            if file_path then
                auto_layout.read_content(file_path, child, position.x, position.y, 'position')
            end
        end

        gui.set_enabled(gui.get_node(child), true)
    end

    if layout == "vertical" then
        total_size.x = auto_layout.get_largest_child_size(layout, children)
        total_size.y = total_size.y - padding
    elseif layout == "horizontal" then
        total_size.y = auto_layout.get_largest_child_size(layout, children)
        total_size.x = total_size.x - padding
    end

    if parent ~= nil then
        gui.set_size(parent, total_size)
        if file_path then
            auto_layout.read_content(file_path, parent_name, total_size.x, total_size.y, 'size')
        end
    end
end

---Setting up a grid layout of a node with its children
---@param parent_name string The name of the grid (parent) node
---@param children table The children within the gird
---@param node_size vector3 The size of the children
---@param max_rows number The max amount of rows
---@param padding number The amount of padding between the children
---@param file_path string The path to a file, this is used when you want to scene view to match the game view
function auto_layout.setup_grid(parent_name, children, node_size, max_rows, padding, file_path)
    local parent = gui.get_node(parent_name)
    local start_x, start_y = 0, 0
    
    for index, child in ipairs(children) do
        local node = gui.get_node(child)
        if index > 1 and (index - 1) % max_rows == 0 then
            start_y = start_y - node_size.y - padding
            start_x = 0
        end
        gui.set_position(node, vmath.vector3(start_x, start_y, 0))
        gui.set_enabled(node, true)

        if file_path then
            auto_layout.read_content(file_path, child, start_x, start_y, 'position')
        end
        start_x = start_x + node_size.x + padding
    end

    local total_columns = math.ceil(#children / max_rows)
    local size_x = (max_rows * node_size.x) + (max_rows - 1) * padding
    local size_y = total_columns * node_size.y + (total_columns - 1) * padding
    gui.set_size(parent, vmath.vector3(size_x, size_y, 0))

    if file_path then
        auto_layout.read_content(file_path, parent_name, size_x, size_y, 'size')
    end
end

---Handles writing the new content of a file
---@param file_path string The path to the file
---@param updated_content string The new contents of the file
function auto_layout.write_content(file_path, updated_content)
    local file = io.open(file_path, "w")
    print('file_path',file_path)

    if file then
        file:write(updated_content)
        
        file:close()
        
        print("File updated successfully.")
    else
        print("Failed to open the file for writing.")
    end
end

---Handles updating the size of a node within a file
---@param id_to_find string The name of the name its looking for
---@param content string The contents of a file
---@param new_size_x number The new width of the node
---@param new_size_y number the new height of the node
---@return string The new content thats gonna be written to the file
function auto_layout.update_node_size(id_to_find, content, new_size_x, new_size_y)
    local updated_content = ""
    local found_id = false

    for line in content:gmatch("[^\r\n]+") do
        if line:find("id: \"" .. id_to_find .. "\"") and not found_id then
            found_id = true
            updated_content = updated_content .. line .. "\n"
            updated_content = updated_content .. string.format("  size {\n    x: %.1f\n    y: %.1f\n    z: 0.0\n    w: 1.0\n  }\n", new_size_x, new_size_y)
        else
            updated_content = updated_content .. line .. "\n"
        end
    end

    return updated_content
end

---Handles updating the size of a node
---@param id_to_find string The name of the name its looking for
---@param content string The contents of a file
---@param new_x number The new width of the node
---@param new_y number the new height of the node
---@return string The new content thats gonna be written to the file
function auto_layout.update_node_position(id_to_find, content, new_x, new_y)
    local updated_content = ""
    local found_id = false

    for line in content:gmatch("[^\r\n]+") do
        if line:find("id: \"" .. id_to_find .. "\"") and not found_id then
            found_id = true
            updated_content = updated_content .. line .. "\n"
            updated_content = updated_content .. string.format("  position {\n    x: %.1f\n    y: %.1f\n    z: 0.0\n    w: 1.0\n  }\n", new_x, new_y)
        else
            updated_content = updated_content .. line .. "\n"
        end
    end

    return updated_content
end

---Handles reading the content of a specific file
---@param file_path string The path to the file
---@param id_to_find string The name of the node your looking for
---@param new_x number The new x size
---@param new_y number The new y size
---@param method string What vaule is gonna be changed ('size'/'position')
function auto_layout.read_content(file_path, id_to_find, new_x, new_y, method)
    local file = io.open(file_path, "r")

    if file then
        local file_contents = file:read("*all")
        
        file:close()

        local updated_content = ''

        if method == "size" then
            updated_content = auto_layout.update_node_size(id_to_find, file_contents, new_x, new_y)
        elseif method == "position" then
            updated_content = auto_layout.update_node_position(id_to_find, file_contents, new_x, new_y)
        end

        auto_layout.write_content(file_path, updated_content)

    else
        print("Failed to open file.txt")
    end
end

return auto_layout