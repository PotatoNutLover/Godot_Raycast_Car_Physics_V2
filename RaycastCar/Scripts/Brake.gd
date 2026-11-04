class_name CarBrake
extends Node3D

@export var velocity_max: float = 15.0
@export var velocity_min: float = 3.0
@export var brake_force_max: float = 5000.0
@export var brake_force_min: float = 2000.0

@export var max_temperature: float = 200.0
@export var max_heating_per_second: float = 100
@export var cooling_per_second: float = 50.0

@export var emission_energy_min: float = 0.0
@export var emission_energy_max: float = 5.0

var _material: StandardMaterial3D
var _temperature: float = 0.0

func _ready() -> void:
	_material = $MeshInstance3D.get_surface_override_material(0)
	
func _physics_process(delta: float) -> void:
	#_temperature = clampf(_temperature - cooling_per_second * delta, 0.0, max_temperature)
	_temperature = clampf(_temperature, 0.0, max_temperature)
	
func get_brake_force(velocity_forward: float, delta: float) -> float:
	if velocity_forward > velocity_min:
		var velocity_percentage: float = velocity_forward / velocity_max
		_temperature = clampf(
			_temperature + max_heating_per_second * velocity_percentage * delta, 
			0.0, 
			max_temperature
			)
	var heating_percent: float = _temperature / max_temperature
	_material.emission_energy_multiplier = clampf(
		heating_percent * emission_energy_max, 
		emission_energy_min, 
		emission_energy_max
	)
	
	var brake_force: float = brake_force_max * (1.0 - heating_percent)
	brake_force = clampf(brake_force, brake_force_min, brake_force_max)
	return brake_force
	
	
func _get_emission_value() -> float:
	return (_temperature / max_temperature) * emission_energy_max
	
