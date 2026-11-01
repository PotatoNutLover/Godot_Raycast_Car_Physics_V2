class_name RaycastCar
extends RigidBody3D

@export_group("Car body params")
@export_range(0.0, 1.0, .01) var air_resistance_coef: float = 0.45
@export_range(0.0, 50000.0,.1,"hide_control") var car_mass: float = 1200.0
#@export var engine_force: float = 10000.0
@export var steering: float = 30.0
@export var steer_speed: float = 8.0
@export var surface_friction: float = 1.0
@export var brake_force: float = 5000.0




var wheels: Array[CarWheel]
var car_engine: CarEngine
var wheel_last_force: float = 0.0


func _ready() -> void:
	center_of_mass = %COM.position
	mass = car_mass
	linear_damp = air_resistance_coef
	car_engine = %CarEngine
	for wheel in %Wheels.get_children():
		if wheel is CarWheel:
			wheel.add_exception(self)
			wheels.append(wheel)

func _physics_process(delta: float) -> void:
	var throttle_input: float = Input.is_action_pressed("ui_up")
	var brake_input: float = Input.is_action_pressed("ui_down")
	var steer_input: float = Input.get_axis("ui_left", "ui_right")
	
	for wheel in wheels:
		wheel.is_grounded = false
		if(wheel.is_steering):
			#wheel.rotation_degrees = Vector3(0,-30*steer_input,0)
			wheel.rotation_degrees.y = lerpf(
				wheel.rotation_degrees.y, 
				-steering * steer_input, 
				steer_speed * delta
				)
			
		if wheel.is_colliding():
			var contact_point: Vector3 = wheel.get_collision_point()
			var contact_normal: Vector3 = wheel.get_collision_normal()
			var spring_up_dir: Vector3 = wheel.global_basis.y
			wheel.is_grounded = true
			
			var wheel_offset = wheel.global_position - global_position
			
			wheel.suspension_current_len = wheel.global_position.distance_to(contact_point)
			wheel.suspension_compression_speed = (wheel.suspension_current_len - wheel.suspension_prev_len) / delta
			var suspension_force = max(0, wheel.spring_force * (wheel.suspension_rest_len - wheel.suspension_current_len) - wheel.suspension_dump * wheel.suspension_compression_speed)
		
			apply_force(suspension_force * contact_normal, wheel_offset)
			wheel.suspension_prev_len = wheel.suspension_current_len
			
			var wheel_vel = _get_point_velocity(contact_point)
			
			var engine_force = car_engine.get_drive_force(wheel_vel.dot(-wheel.global_basis.z), throttle_input, wheel.wheel_radius, 4)
			
			var force_long: float = engine_force * throttle_input - brake_force * brake_input * sign(wheel_vel.dot(-wheel.global_basis.z)) - 10 * wheel_vel.dot(-wheel.global_basis.z)
			var force_lat: float = -wheel_vel.dot(wheel.global_basis.x) * 15000
			var force_max = surface_friction * suspension_force
			var force_tire_desired = force_long * -wheel.global_basis.z + force_lat * wheel.global_basis.x
			
			var force_tire = force_tire_desired
			var desired_magnitude = force_tire_desired.length()
			
			if desired_magnitude > force_max and desired_magnitude > 0.001:
				force_tire = (force_tire_desired / desired_magnitude) * force_max
			
			wheel.update_wheel_visual(delta, wheel_vel.dot(-wheel.global_basis.z))
			apply_force(force_tire, wheel_offset)
			wheel_last_force = force_long
		wheel.update_wheel_visual(delta, 0)
			
			
func _get_point_velocity(point_global_pos: Vector3) -> Vector3:
	var r: Vector3 = point_global_pos - (global_position + global_basis * center_of_mass)
	return linear_velocity + angular_velocity.cross(r)
			
			
			
			
			
