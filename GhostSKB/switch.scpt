on switch()
	tell application "System Events"
		key code 49 using {command down}
	end tell
end switch

on switch_command(key)
	tell application "System Events"
		key code key using {command down}
	end tell
end switch_command

on switch_control(key)
	tell application "System Events"
		key code key using {control down}
	end tell
end switch_control

on switch_option(key)
	tell application "System Events"
		key code key using {option down}
	end tell
end switch_option

on switch_command_shift(key)
	tell application "System Events"
		key code key using {command down, shift down}
	end tell
end switch_command_shift

on switch_command_option(key)
	tell application "System Events"
		key code key using {command down, option down}
	end tell
end switch_command_option

on switch_command_control(key)
	tell application "System Events"
		key code key using {command down, control down}
	end tell
end switch_command_control

on switch_control_shift(key)
	tell application "System Events"
		key code key using {control down, shift down}
	end tell
end switch_control_shift

on switch_control_option(key)
	tell application "System Events"
		key code key using {control down, option down}
	end tell
end switch_control_option

on switch_option_shift(key)
	tell application "System Events"
		key code key using {option down, shift down}
	end tell
end switch_option_shift

on switch_command_control_shift(key)
	tell application "System Events"
		key code key using {command down, control down, shift down}
	end tell
end switch_command_control_shift

on switch_command_control_option(key)
	tell application "System Events"
		key code key using {command down, control down, option down}
	end tell
end switch_command_control_option

on switch_control_option_shift(key)
	tell application "System Events"
		key code key using {control down, option down, shift down}
	end tell
end switch_control_option_shift

on switch_command_option_shift(key)
	tell application "System Events"
		key code key using {command down, option down, shift down}
	end tell
end switch_command_option_shift

on switch_command_control_option_shift(key)
	tell application "System Events"
		key code key using {command down, control down, option down, shift down}
	end tell
end switch_command_control_option_shift

