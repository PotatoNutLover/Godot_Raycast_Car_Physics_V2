class_name RaycastCar
extends RigidBody3D

signal shift_changed

@export_group("Car body params")
@export_range(0.0, 1.0, .01) var air_resistance_coef: float = 0.45
@export_range(0.0, 50000.0,.1,"hide_control") var car_mass: float = 1200.0
@export var steering: float = 30.0
@export var steer_speed: float = 8.0
@export var brake_force: float = 5000.0
@export_range(0.0, 1.0, .01) var rolling_resistance_coef: float = 0.5

var wheels: Array[CarWheel]
var drive_wheels_count: int = 0
var car_engine: CarEngine
var car_transmission: CarTransmission
var car_systems: CarSystems

var _throttle_input: float = 0.0
var _brake_input: float = 0.0
var _steer_input: float = 0.0
var _run_time: float = 0.0
var _wheels_on_ground: int = 0

func _ready() -> void:
	set_default_com()
	mass = car_mass
	linear_damp = air_resistance_coef
	car_engine = %CarEngine
	car_transmission = %CarTransmission
	car_engine.set_transmission(car_transmission)
	car_systems = %CarSystems
	for wheel in %Wheels.get_children():
		if wheel is CarWheel:
			if wheel.is_traction:
				drive_wheels_count += 1
			wheel.add_exception(self)
			wheels.append(wheel)


func _physics_process(delta: float) -> void:
	_read_input()
	if is_on_ground():
		make_bob_effect(delta)
		set_default_com()
	else:
		set_air_com()
	
	_wheels_on_ground = 0
	
	for wheel in wheels:
		wheel.is_grounded = false
		if(wheel.is_steering):
			_handle_steering(wheel, _steer_input, delta)
			
		if wheel.is_colliding():
			var contact_point: Vector3 = wheel.get_collision_point()
			var contact_normal: Vector3 = wheel.get_collision_normal()
			wheel.is_grounded = true
			_wheels_on_ground += 1
			var wheel_offset = wheel.global_position - global_position
			
			var suspension_force: float = wheel.calculate_suspension_force(contact_point, delta)
			
			apply_force(suspension_force * contact_normal, wheel_offset)
			
			var wheel_vel = _get_point_velocity(contact_point)
			var velocity_forward = wheel_vel.dot(-wheel.global_basis.z)
			var velocity_lat = wheel_vel.dot(wheel.global_basis.x)
	
			var engine_force = car_engine.get_drive_force(
				velocity_forward, 
				_throttle_input, 
				wheel.wheel_radius, 
				drive_wheels_count,
				delta
				)
			
			var force_tire: Vector3 = calculate_force_per_tire(
				engine_force,
				brake_force,
				suspension_force,
				velocity_forward,
				velocity_lat,
				wheel)
			
			wheel.update_wheel_visual(delta, velocity_forward)
			apply_force(force_tire, wheel_offset)
		wheel.update_wheel_visual(delta, 0)
			
func calculate_force_per_tire(engine_force: float, brake_force: float, suspension_force: float, v_forward: float, v_lat: float, wheel: CarWheel) -> Vector3:
	engine_force = engine_force * _throttle_input
	#if _brake_input != 0:
		#engine_force = 0
		
	var rolling_resisnance: float = rolling_resistance_coef * v_forward
	#brake_force = brake_force * _brake_input * sign(v_forward)
	brake_force = brake_force * _brake_input * clamp(v_forward / 0.3, -1.0, 1.0)
	var force_forward: float = engine_force - rolling_resisnance
	if _brake_input > 0:
		force_forward -= brake_force

			
	var force_max = wheel.surface_viscosity * suspension_force
	var force_lat: float = -v_lat * wheel.cornering_stiffness * wheel.surface_traction# можно моделировать в зависимости от покрытия (меньше - скольжение, больше - удержание)
			
	
	
	var force_tire_desired = force_forward * -wheel.global_basis.z + force_lat * wheel.global_basis.x
	var force_tire = force_tire_desired
	var desired_magnitude = force_tire_desired.length()
	if desired_magnitude > force_max and desired_magnitude > 0.05:
		force_tire = (force_tire_desired / desired_magnitude) * force_max
		
		
	return force_tire


func _handle_steering(wheel: CarWheel, _steer_input: float, delta: float) -> void:
	wheel.rotation_degrees.y = lerpf(
				wheel.rotation_degrees.y, 
				-steering * _steer_input, 
				steer_speed * delta
				)


func _read_input() -> void:
	_throttle_input = Input.is_action_pressed("ui_up")
	_brake_input= Input.is_action_pressed("ui_down")
	_steer_input = Input.get_axis("ui_left", "ui_right")
	
	if (Input.is_action_just_pressed("shift_up")):
		car_transmission.shift_up()
		shift_changed.emit()
	elif(Input.is_action_just_pressed("shift_down")):
		car_transmission.shift_down()
		shift_changed.emit()

func get_car_info() -> CarInfo:
	return car_systems.get_car_info()

func is_on_ground() -> bool:
	if _wheels_on_ground == len(wheels):
		return true
	return false
	
func set_default_com() -> void:
	center_of_mass = %COM.position
	
func set_air_com() -> void:
	center_of_mass = %COM_air.position
		
func make_bob_effect(delta: float) -> void:
	_run_time += delta
	%CarBody.rotation = Vector3(0,0, car_engine.get_bob_effect_rotation_z_rad(_run_time))
		
	
func _get_point_velocity(point_global_pos: Vector3) -> Vector3:
	var r: Vector3 = point_global_pos - (global_position + global_basis * center_of_mass)
	return linear_velocity + angular_velocity.cross(r)
			
			
			
			
			
