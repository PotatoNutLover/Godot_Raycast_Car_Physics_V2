class_name CarSystems
extends Node

var car_info: CarInfo
var car_engine: CarEngine
var car_transmission: CarTransmission

func _ready() -> void:
	car_info = CarInfo.new()
	car_engine = $CarEngine
	car_transmission = $CarTransmission
	
func get_car_info() -> CarInfo:
	car_info.set_info(
		car_transmission.current_gear,
		car_transmission.get_current_gear_label(),
		car_engine.current_rpm,
		car_engine.max_rpm
	)
	return car_info
	
