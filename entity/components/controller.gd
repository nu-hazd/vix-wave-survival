extends Node
class_name ControllerComponent

enum DIRECTION { UP, DOWN, LEFT, RIGHT }


var directionArray : Array[bool] = [0, 0, 0, 0]
var actionQueue : Array[StringName] = []

func setDirection(dir : DIRECTION, val : bool) -> void:
	directionArray[dir] = val
func getDirectionArray() -> Array[bool]:
	return directionArray
func addDesiredAction(act : StringName) -> void:
	actionQueue.push_back(act)
func getFrontAction() -> StringName:
	if not actionQueue.is_empty():
		return actionQueue.pop_front()
	return &""
