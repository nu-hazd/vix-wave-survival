class_name MovementComponent extends StateMachine

@export var entity : Entity
@export var controller : ControllerComponent
@onready var anim_hanlder: AnimationTree = $animHanlder
var lastDir : Vector2 = Vector2.DOWN 
func _ready() -> void:
	for movementState in $states.get_children() as Array[MovementState]:
		movementState.entity = entity
		movementState.animHandler = anim_hanlder
		movementState.controller = controller
	super._ready()
func process(delta) -> void:
	super.process(delta)
	print(getCurrentStateName())

func push(duration : float, distance : Vector2):
	pass
	
