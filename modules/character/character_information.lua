local character_looks = require('modules.character.character_looks')

local character_info = {}

character_info.walking_dir = vmath.vector3()
character_info.direction = 'down'
character_info.looks = character_looks

return character_info