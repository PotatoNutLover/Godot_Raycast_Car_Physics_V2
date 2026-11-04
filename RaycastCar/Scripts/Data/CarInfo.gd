class_name CarInfo
extends Resource

var current_gear_index: int = 0
var current_gear: String = ''
var current_rpm: float = 0.0
var max_rpm: float = 0.0

func set_info(gear_index: int, gear: String, rpm: float, max_rpm: float) -> void:
	current_gear_index = gear_index
	current_gear = gear
	current_rpm = rpm
	self.max_rpm = max_rpm
