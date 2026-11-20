class_name MufflerParticles
extends GPUParticles3D

@export_range(0.0,1.0,0.01) var min_amount_ratio: float = 0.2
@export_range(0.0,1.0,0.01) var max_amount_ratio: float = 1.0
@export var min_color: Color
@export var max_color: Color

func start_emit() -> void:
	emitting = true
	restart()
	
func stop_emit() -> void:
	emitting = false
	
func set_ratio(ratio: float) -> void:
	amount_ratio = lerpf(min_amount_ratio, max_amount_ratio, ratio)
	(process_material as ParticleProcessMaterial).color = lerp(min_color, max_color, ratio)
