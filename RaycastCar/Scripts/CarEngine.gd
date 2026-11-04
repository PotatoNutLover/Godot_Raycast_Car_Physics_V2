class_name CarEngine
extends Node

@export_group("Engine Specs")
@export var idle_rpm: float = 1000.0
@export var max_rpm: float = 7000.0
@export var max_torque: float = 300.0
@export var engine_breaking: float = 90.0
@export var rpm_accel_free: float = 12.0
@export var rpm_deccel_free: float = 12.0
@export var torque_curve: Curve
@export var body_torque_freqency: float = 50.0
@export var body_torque_amount: float = 0.001
@export var body_torque_thereshold_rpm: float = 2000

#var final_drive: float = 8.0
#var gear: float = 3.2
#var transmission_efficiency_factor: float = 0.9

var current_rpm: float = 0.0
var target_rpm: float = 0.0
var transmission: CarTransmission

var _bob_effect_rotation_z_rad: float = 0.0

func get_drive_force(
		force_long: float, 
		throttle: float, 
		wheel_radius: float, 
		drive_wheels_count: int,
		delta: float
		) -> float:
	if is_connected_to_transmission(transmission):
		current_rpm = (force_long * transmission.get_final_ratio() * (60 / TAU)) / wheel_radius
		if current_rpm < 2000 and throttle > 0:
			var slip = lerpf(idle_rpm, 2000 + randf_range(-120, 0), throttle)
			current_rpm = max(current_rpm, slip)
	elif transmission.shift_timer > 0.0 and transmission.current_gear != transmission.neutral_gear_index:
		var target_rpm = (force_long * transmission.get_final_ratio() * (60 / TAU)) / wheel_radius
		current_rpm = lerpf(current_rpm, target_rpm, 1.0 - transmission.shift_timer / transmission.shift_duration)
	elif throttle > 0:
		current_rpm += torque_curve.sample_baked(current_rpm / max_rpm) * max_torque * rpm_accel_free * delta
	else:
		current_rpm -= torque_curve.sample_baked(current_rpm / max_rpm) * rpm_deccel_free * delta
		
	current_rpm = clampf(current_rpm, idle_rpm +randf_range(-120,120), max_rpm + randf_range(-120, 0))
	var torque = torque_curve.sample_baked(current_rpm / max_rpm) * max_torque
	var drive_force = 0.0
	if is_connected_to_transmission(transmission):
		drive_force = torque * throttle * transmission.get_final_ratio() * transmission.efficiency_factor
		drive_force = drive_force / (wheel_radius * drive_wheels_count)
	
	return drive_force
	
func is_connected_to_transmission(transmission: CarTransmission) -> bool:
	if (
		transmission.shift_timer == 0.0 
		and transmission.current_gear != transmission.neutral_gear_index
		and not transmission.is_clutch_pressed):
		return true
	return false
	
func get_bob_effect_rotation_z_rad(time: float) -> float:
	_bob_effect_rotation_z_rad = sin(
			time * body_torque_freqency
			) * current_rpm * 0.001 * body_torque_amount / 100
	if (current_rpm < (body_torque_thereshold_rpm + randf_range(-120,0))) or is_connected_to_transmission(transmission):
		_bob_effect_rotation_z_rad = 0.0
	
	return _bob_effect_rotation_z_rad
	
func set_transmission(transmission: CarTransmission) -> void:
	self.transmission = transmission
