local interaction_name = "pickaxe"
local startDown = 1
local startUp = 41
local startRight = 81
local startLeft = 121
local totalFrames = 5
for index = 0, 7, 1 do
	local test =  [[
		animations {
			id: "]] .. interaction_name .. [[_down_]] .. index .. [["
			start_tile: ]] .. startDown .. [[
			end_tile: ]] .. startDown + (totalFrames - 1) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: ]] .. totalFrames .. [[
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "]] .. interaction_name .. [[_left_]] .. index .. [["
			start_tile: ]] .. startLeft .. [[
			end_tile: ]] .. startLeft + (totalFrames - 1) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: ]] .. totalFrames .. [[
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "]] .. interaction_name .. [[_right_]] .. index .. [["
			start_tile: ]] .. startRight .. [[
			end_tile: ]] .. startRight + (totalFrames - 1) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: ]] .. totalFrames .. [[
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "]] .. interaction_name .. [[_up_]] .. index .. [["
			start_tile: ]] .. startUp .. [[
			end_tile: ]] .. startUp + (totalFrames - 1) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: ]] .. totalFrames .. [[
			flip_horizontal: 0
			flip_vertical: 0
		}
		]]
	--print(test)
	startDown = startDown + totalFrames
	startUp = startUp + totalFrames
	startRight = startRight + totalFrames
	startLeft = startLeft + totalFrames
end

startDown = 1
startUp = 41
startRight = 81
startLeft = 121

for index = 0, 7, 1 do
	local test =  [[
		animations {
			id: "idle_down_]] .. index .. [["
			start_tile: ]] .. startDown .. [[
			end_tile: ]] .. startDown .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "idle_left_]] .. index .. [["
			start_tile: ]] .. startLeft .. [[
			end_tile: ]] .. startLeft .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "idle_right_]] .. index .. [["
			start_tile: ]] .. startRight .. [[
			end_tile: ]] .. startRight .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "idle_up_]] .. index .. [["
			start_tile: ]] .. startUp .. [[
			end_tile: ]] .. startUp .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "walk_down_]] .. index .. [["
			start_tile: ]] .. startDown .. [[
			end_tile: ]] .. (startDown + 7) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "walk_left_]] .. index .. [["
			start_tile: ]] .. startLeft .. [[
			end_tile: ]] .. (startLeft + 7) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "walk_right_]] .. index .. [["
			start_tile: ]] .. startRight .. [[
			end_tile: ]] .. (startRight + 7) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		animations {
			id: "walk_up_]] .. index .. [["
			start_tile: ]] .. startUp .. [[
			end_tile: ]] .. (startUp + 7) .. [[
			playback: PLAYBACK_LOOP_FORWARD
			fps: 8
			flip_horizontal: 0
			flip_vertical: 0
		}
		]]
	--print(test)
	startDown = startDown + 8
	startUp = startUp + 8
	startRight = startRight + 8
	startLeft = startLeft + 8
end