extends Node3D

var player_car: RaycastCar
var car_ui: CarUI

func _ready() -> void:
	player_car = $Car
	car_ui = $CarUI
	
	var car_info: CarInfo = player_car.get_car_info()
	car_ui.set_rpm_label(car_info.current_rpm)
	car_ui.set_rpm_progress_bar(car_info.current_rpm, car_info.max_rpm)
	car_ui.set_gear_label(car_info.current_gear)
	
func _physics_process(delta: float) -> void:
	update_car_ui()
	
func update_car_ui() -> void:
	var car_info: CarInfo = player_car.get_car_info()
	car_ui.set_rpm_label(car_info.current_rpm)
	car_ui.set_rpm_progress_bar(car_info.current_rpm, car_info.max_rpm)
	

func _on_car_shift_changed() -> void:
	var car_info: CarInfo = player_car.get_car_info()
	car_ui.set_gear_label(car_info.current_gear)
