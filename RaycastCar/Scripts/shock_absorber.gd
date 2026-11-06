class_name ShockAbsorber
extends Node3D

@export var arm_min_rotation_y: float = -30.0
@export var arm_max_rotation_y: float = 30.0
@export var spring_min_compression: float = 0.6
@export var spring_max_compression: float = 1.45
@export_range(-1.0, 1.0, 0.01) var marker_pos_x = 0.0

var _spring_material: ShaderMaterial
var _arm: Node3D
var _marker: Node3D

func _ready() -> void:
	_marker = %Marker3D
	_arm = %arm
	_spring_material = %sa_spring.get_surface_override_material(0) as ShaderMaterial
	

func _physics_process(delta: float) -> void:
	#_marker.position = Vector3(marker_pos_x, 0,0.44)
	var arm_rotation_degrees:float = _arm.rotation_degrees.y + 30.0
	var percent: float = arm_rotation_degrees / 60.0
	var spring_compression = lerp(0.6, 1.45, percent)
	_spring_material.set_shader_parameter('Compression', spring_compression)
	
func set_marker_global_pos(pos: Vector3) -> void:
	_marker.global_position = pos
	
	
