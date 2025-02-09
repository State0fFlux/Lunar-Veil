extends Node

# Append to array whenever new powers are acquired
var powers = ["umbra_shift", "gemini's_trick", "star blaster"]
var current_power_index = 0
var current_power = powers[current_power_index]

var is_power_active = false

# represents if a power is charging up, and to what degree it is charged
var charging = false
var charge = 0.0

signal power_changed(new_power)

func _input(event):
	if event.is_action_pressed("next_power"):
		current_power_index = (current_power_index + 1) % powers.size()
		power_changed.emit(powers[current_power_index])
		current_power = powers[current_power_index]

	elif event.is_action_pressed("prev_power"):
		current_power_index = (current_power_index - 1 + powers.size()) % powers.size()
		power_changed.emit(powers[current_power_index])
		current_power = powers[current_power_index]
