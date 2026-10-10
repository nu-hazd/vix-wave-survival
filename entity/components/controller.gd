extends Node
class_name ControllerComponent

var direction : Vector2 = Vector2.ZERO
var lastAction : StringName 
signal emitAction(act : StringName)

func setDirection(dir : Vector2) -> void:
	direction = dir
func getDirectionArray() -> Vector2:
	return direction
func setAction(act : StringName) -> void:
	lastAction = act
	emitAction.emit(act)
