class_name Vix extends Entity

@export var camera : Camera2D 

func disableCombat() -> void:
	$ui.visible = false
	$controller.set_process_unhandled_input(false)
func enableCombat() -> void:
	$ui.visible = true
	$controller.set_process_unhandled_input(true)
