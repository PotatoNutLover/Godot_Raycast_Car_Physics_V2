class_name CarWheel
extends RayCast3D

@export var is_traction: bool = false
@export var is_steering: bool = false
@export var wheel_radius: float = 0.225
@export var suspension_rest_len: float = 0.3
@export var suspension_dump: float = 100.0
@export var spring_force: float = 1000.0
@export var cornering_stiffness: float = 15000.0
@export var surface_viscosity: float = 1.0
@export var surface_traction: float = 1.0
var suspension_current_len: float = 0.0
var suspension_prev_len: float = 0.0
var suspension_compression_speed: float = 0.0

var is_grounded: bool = false
var wheel_mesh: Node3D
var car_brake: CarBrake

var _suspension_force: float = 0.0
var _remaining_suspension_len: float = 0.0

func _ready() -> void:
	target_position = Vector3(0, -(suspension_rest_len + wheel_radius), 0)
	suspension_current_len = suspension_rest_len
	suspension_prev_len = suspension_current_len
	wheel_mesh = get_child(0)
	car_brake = get_child(1)

func calculate_suspension_force(contact_point: Vector3, delta: float) -> float:
	suspension_current_len = global_position.distance_to(contact_point)
	suspension_compression_speed = (suspension_current_len - suspension_prev_len) / delta
	_remaining_suspension_len = suspension_rest_len + wheel_radius - suspension_current_len
	_suspension_force = max(
		0, 
		spring_force * _remaining_suspension_len - suspension_dump * suspension_compression_speed
		)
	suspension_prev_len = suspension_current_len
	return _suspension_force

func update_wheel_visual(delta: float, forward_vel: float) -> void:
	if(is_grounded):
		wheel_mesh.position.y = move_toward(
			wheel_mesh.position.y, 
			-(max(0,suspension_current_len - wheel_radius)), 
			5.0 * delta
			)
	else:
		wheel_mesh.position.y = move_toward(
			wheel_mesh.position.y, 
			-suspension_rest_len, 
			5.0 * delta
			)	
	wheel_mesh.rotate_x(-forward_vel / wheel_radius * delta)

func get_brake_force(velocity_forward: float, delta: float) -> float:
	return car_brake.get_brake_force(velocity_forward, delta)
