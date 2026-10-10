extends Node
class_name StateMachine

var currentState : State
@export var initialState : State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentState = initialState
	currentState.onEnter()
	currentState.nextState = null

func process(delta) -> void:
	if currentState.nextState != null:
		currentState.onExit()
		currentState = currentState.nextState
		currentState.onEnter()
		currentState.nextState = null
	currentState.process(delta)


func setCurrentState(newState : State) -> bool:
	if newState == null:
		push_error("At: " + get_parent().name + "; attempting to set an invalid, or null, state. Check State node names and script state references. (There might be a typo.) "  )
		return false
	currentState.onExit()
	currentState = newState
	currentState.onEnter()
	currentState.nextState = null
	return true

func getCurrentStateName() -> String:
	return currentState.name
