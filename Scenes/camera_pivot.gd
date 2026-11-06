class_name CarCamera
extends Node3D

@export var default_pos: Vector3
@export var default_rot: Vector3
@export var option_1_pos: Vector3
@export var option_1_rot: Vector3
@export var option_2_pos: Vector3
@export var option_2_rot: Vector3

var player_car: RaycastCar

func _physics_process(delta: float) -> void:
	global_position = player_car.global_position
	if Input.is_action_pressed("camera_option_1"):
		$Camera3D.position = option_1_pos
		rotation_degrees = player_car.rotation_degrees * Vector3(0,1,0) + option_1_rot
	elif Input.is_action_pressed("camera_option_2"):
		$Camera3D.position = option_2_pos
		rotation_degrees = player_car.rotation_degrees * Vector3(0,1,0) + option_2_rot
	else:
		$Camera3D.position = default_pos
		rotation_degrees = player_car.rotation_degrees * Vector3(0,1,0) + default_rot
