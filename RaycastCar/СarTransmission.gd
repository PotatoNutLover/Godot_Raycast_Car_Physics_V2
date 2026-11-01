class_name CarTransmission
extends Node

@export var gear_ratios: Array[float] = [-3.2, 0.0, 3.2, 2.1, 1.5, 1.1]
@export var final_drive: float = 8.0
@export var shift_duration: float = 0.15
@export_range(0.0, 1.0, 0.01) var efficiency_factor: float = 0.9
@export var start_gear_index = 1

var current_gear: int = 0
var shift_timer: float = 0.0
var is_clutch_pressed: bool = false

func _ready() -> void:
	current_gear = start_gear_index
	
func _physics_process(delta: float) -> void:
	if shift_timer > 0.0:
		shift_timer = clampf(shift_timer - delta, 0.0, shift_duration)

func shift_up() -> void:
	if shift_timer == 0.0:
		current_gear = clamp(current_gear + 1, 0, len(gear_ratios) - 1)
		shift_timer = shift_duration
		
func shift_down() -> void:
	if shift_timer == 0.0:
		current_gear = clamp(current_gear - 1, 0, len(gear_ratios) - 1)
		shift_timer = shift_duration
		
func get_final_ratio() -> float:
	return final_drive * gear_ratios[current_gear]
	
func get_current_gear_label() -> String:
	if current_gear == 0:
		return 'R'
	elif current_gear == 1:
		return 'N'
	return str(current_gear - 1) 
		
