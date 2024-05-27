---@diagnostic disable: cast-local-type

local item_definitions = require('modules.utility.item_definitions')

---@return table animations The new container instance.
local container = {}

--- Creates a new instance of the container
function container.new()
    local instance = {
        container_size = 0,
        container_type = 'standard',
        allow_shifting = false,
        container_changed_callback = nil,
        items = {},
        stack_types = {
            STANDARD = 'standard',
            ALWAYS_STACK = 'always stack'
        },
        updated_slots = {}
    }

    function instance.initilize(container_size, container_type, allow_shifting, container_changed_callback)
        instance.container_size = container_size
        instance.container_type = container_type
        instance.allow_shifting = allow_shifting
        instance.container_changed_callback = container_changed_callback
        for index = 1, container_size + 1, 1 do
            instance.items[index] = {
                id = -1,
                amount = 0,
                durability = -1,
                max_durability = -1
            }
        end
    end

    function instance.set(slot, item_data, update)
        instance.items[slot] = item_data
        instance.updated_slots[#instance.updated_slots + 1] = slot
        if update then
            instance.container_changed_callback()
        end
    end

    function instance.swap(from, to, update)
        local temp = instance.items[from]

        instance.items[from] = instance.items[to]
        instance.items[to] = temp

        instance.updated_slots[#instance.updated_slots + 1] = from
        instance.updated_slots[#instance.updated_slots + 1] = to
        
        if update then
            instance.container_changed_callback()
        end
    end

    function instance.add(item_id, item_amount)
        item_amount = item_amount or 1
        if not instance.fits_container() then
            print('There is no room for the item ', item_id)
            return
        end

        local new_slot = instance.get_free_slot()
        local stackable = item_definitions.definitions[item_id].stackable
        if (stackable or instance.container_type == instance.stack_types.ALWAYS_STACK) and instance.has_item(item_id, item_amount) then
            print('Get existing slot for ',item_id)
            new_slot = instance.get_slot(item_id)
        end

        if new_slot == -1 then
            print('No slot to add the item ',item_id)
            return
        end

        if stackable or instance.container_type == 'always stack' then
            local item_data = instance.items[new_slot]
            if item_data.id == -1 then
                item_data.id = item_id
            end

            local total_amount = item_data.amount + item_amount
            if total_amount < 1 then
                print('total_amount cannot be lower then 1')
                return
            end
            item_data.amount = total_amount
            instance.updated_slots[#instance.updated_slots + 1] = new_slot

        else
            for _ = 1, item_amount, 1 do
                local free_slot = instance.get_free_slot()
                if free_slot == -1 then
                    print('No more free slots were found...')
                    return
                end
                local item_data = instance.items[free_slot]

                item_data.id = item_id
                item_data.amount =  1
                instance.updated_slots[#instance.updated_slots + 1] = free_slot
            end
        end

        instance.container_changed_callback()
    end

    function instance.remove(item_id, item_amount, allow_zero, prefered_slot)
        item_amount = item_amount or 1
        allow_zero = allow_zero or false
        prefered_slot = prefered_slot or -1
        local slot = prefered_slot or -1
        if slot == -1 then
            slot = instance.get_slot(item_id)
        end

        if slot == -1 then
            print('There is no slot found with this item',item_id)
            return
        end

        local item_data = instance.items[slot]
        local shift_contrainer = false
        local stackable = item_definitions.definitions[item_id].stackable
        
        if item_data.id == -1 then
            print('There is no item in slot ',slot)
            return
        end

        if stackable or instance.container_type == instance.stack_types.ALWAYS_STACK then
            if item_data.amount > item_amount then
                item_data.amount = item_data.amount - item_amount
            else
                if not allow_zero then
                    item_data.id = -1
                end
                item_data.amount = 0
                shift_contrainer = true
            end
            instance.updated_slots[#instance.updated_slots + 1] = slot
        else
            for index = 1, item_amount, 1 do
                slot = instance.get_slot(item_id)
                if index == 1 and prefered_slot ~= -1 then
                    local item_data = instance.items[prefered_slot]
                    if item_data.id == item_id then
                        slot = prefered_slot
                    end
                end
                
                if slot ~= -1 then
                    local item_data = instance.items[slot]
                    item_data.id = -1
                    item_data.amount = 0

                    instance.updated_slots[#instance.updated_slots + 1] = slot
                else
                    print('There is no item to remove ',item_id)
                end
            end
        end

        if instance.allow_shifting and shift_contrainer then
            instance.shift_container()
        end
        
        instance.container_changed_callback()
    end

    function instance.fits_container()
        for index = 1, #instance.items, 1 do
            if instance.items[index].id == -1 then
                return true
            end
        end
        return false
    end

    function instance.get_free_slot()
        for index = 1, #instance.items, 1 do
            if instance.items[index].id == -1 then
                return index
            end
        end
        return -1
    end

    function instance.has_item(item_id, item_amount)
        for index = 1, #instance.items, 1 do
            local item_data = instance.items[index]
            if item_data.id == item_id and item_data.amount >= item_amount then
                return
            end
        end
        return false
    end

    function instance.get_slot(item_id)
        for index = 1, #instance.items, 1 do
            local item_data = instance.items[index]
            if item_data.id == item_id then
                return index
            end
        end
        return -1
    end

    function instance.shift_container()
        
    end

    function instance.print_container()
        for slot, item in pairs(instance.items) do
            if item.id ~= -1 then
                print('slot: ' .. slot .. ' name: ' .. item_definitions.definitions[item.id].name .. ' id: ' .. item.id .. ' amount: ' .. item.amount)
            else
                
                print('slot: ' .. slot .. ' id: ' .. item.id .. ' amount: ' .. item.amount)
            end
        end
    end

    function instance.get_updated_items()
        local items = {}
        for index = 1, #instance.updated_slots, 1 do
            items[#items + 1] = {
                slot = instance.updated_slots[index],
                item = instance.items[instance.updated_slots[index]]
            }
        end
        print('items',items)
        instance.updated_slots = { }
        return items
    end

    return instance
end

return container
