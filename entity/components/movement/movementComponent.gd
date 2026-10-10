class_name MovementComponent extends StateMachine 

var targetCharacterBody : CombatEntity
var controller : ControllerComponent
var facingDirection : Vector2

@onready var sprite: Sprite2D = $"../sprite"
@onready var blendspace: AnimationTree = $blendspace
# Called when the node enters the scene tree for the first time.
func setup() -> void:
	var states := $states.get_children()
	for state : MovementState in states:
		pass
		

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
