class_name CarCamera
extends Node3D

var player_car: RaycastCar

func _physics_process(delta: float) -> void:
	global_position = player_car.global_position
	if Input.is_action_pressed("camera_option_1"):
		rotation_degrees = Vector3(rotation_degrees.x, player_car.rotation_degrees.y - 110, rotation_degrees.z)
	else:
		rotation_degrees = Vector3(rotation_degrees.x, player_car.rotation_degrees.y, rotation_degrees.z)
