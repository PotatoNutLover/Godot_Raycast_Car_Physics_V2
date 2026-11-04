class_name CarUI
extends CanvasLayer

@onready var gear_label: Label = $LabelCurrentGear 
@onready var rpm_label: Label = $LabelCurrentRPM
@onready var rpm_progress_bar: ProgressBar = $ProgressBarCurrentRPM


func set_gear_label(gear: String) -> void:
	gear_label.text = "Current gear: %s" % gear
	
func set_rpm_label(rpm: float) -> void:
	rpm_label.text = "Current RPM: %s" % str(int(rpm))
	
func set_rpm_progress_bar(rpm: float, max_rpm: float) -> void:
	rpm_progress_bar.value = rpm / max_rpm * 100
