extends Node
class_name ControllerComponent

const attack0 : StringName = &"attack0"
const attack1 : StringName = &"attack1"
const block : StringName = &"block"
const unblock : StringName = &"unblock"
const dodge : StringName = &"dodge"

var validActions : Array[StringName] = [attack0,attack1,block,unblock,dodge]
var direction : Vector2 = Vector2.ZERO
signal actionRequested(act : StringName)
signal directionChanged(newDirection : Vector2)

func setDirection(dir : Vector2) -> void:
	if dir != direction:
		direction = dir
		directionChanged.emit(dir)
func getCurrentDirection() -> Vector2:
	return direction
func requestAction(act : StringName) -> void:
	if act in validActions:
		actionRequested.emit(act)
