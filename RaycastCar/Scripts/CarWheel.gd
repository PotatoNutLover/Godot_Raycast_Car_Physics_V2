class_name CarWheel
extends RayCast3D

@export var is_traction: bool = false
@export var is_steering: bool = false
@export var wheel_radius: float = 0.225
@export var suspension_rest_len: float = 0.3
@export var suspension_dump: float = 100.0
@export var spring_force: float = 1000.0
var suspension_current_len: float = 0.0
var suspension_prev_len: float = 0.0
var suspension_compression_speed: float = 0.0

var is_grounded: bool = false
var wheel_mesh: Node3D

func _ready() -> void:
	target_position = Vector3(0, -(suspension_rest_len + wheel_radius), 0)
	suspension_current_len = suspension_rest_len
	suspension_prev_len = suspension_current_len
	wheel_mesh = get_child(0)


func update_wheel_visual(delta: float, forward_vel: float) -> void:
	if(is_grounded):
		wheel_mesh.position.y = move_toward(
			wheel_mesh.position.y, 
			-(suspension_current_len - wheel_radius), 
			5.0 * delta
			)
	else:
		wheel_mesh.position.y = move_toward(
			wheel_mesh.position.y, 
			-suspension_rest_len, 
			5.0 * delta
			)	
	wheel_mesh.rotate_x(-forward_vel / wheel_radius * delta)
		
