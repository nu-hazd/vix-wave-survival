class_name Enemy extends Entity 

#@export var movement: MovementComponent 
#@export var controller : ControllerComponent
#
#
#
func _ready() -> void:
	health = maxHealth
	#movement.targetCombatEntity = self
	#movement.controller = controller
#func _process(delta: float) -> void:
	#pass
