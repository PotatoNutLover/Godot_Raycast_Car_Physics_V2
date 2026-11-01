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

#var final_drive: float = 8.0
#var gear: float = 3.2
#var transmission_efficiency_factor: float = 0.9

var current_rpm: float = 0.0

func get_drive_force(
		force_long: float, 
		throttle: float, 
		wheel_radius: float, 
		drive_wheels_count: int, 
		transmission: CarTransmission,
		delta: float
		) -> float:
	if is_connected_to_transmission(transmission):
		current_rpm = (force_long * transmission.get_final_ratio() * (60 / TAU)) / wheel_radius
	elif throttle > 0:
		current_rpm += torque_curve.sample_baked(current_rpm / max_rpm) * max_torque * rpm_accel_free * delta
	else:
		current_rpm -= torque_curve.sample_baked(current_rpm / max_rpm) * rpm_deccel_free * delta
		
	current_rpm = clampf(current_rpm, idle_rpm, max_rpm)
	var torque = torque_curve.sample_baked(current_rpm / max_rpm) * max_torque
	var drive_force = 0.0
	if is_connected_to_transmission(transmission):
		drive_force = torque * throttle * transmission.get_final_ratio() * transmission.efficiency_factor
		drive_force = drive_force / (wheel_radius * drive_wheels_count)
	
	return drive_force
	
func is_connected_to_transmission(transmission: CarTransmission) -> bool:
	if (
		transmission.shift_timer == 0.0 
		and transmission.current_gear != 1 
		and not transmission.is_clutch_pressed):
		return true
	return false
