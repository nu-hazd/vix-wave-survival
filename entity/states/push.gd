extends MovementState
class_name PushState

const pushSpeed : int = 100


var pushDirection : Vector2 = Vector2.ZERO
var ticksRemaining: int = 0

# Based on Guard damage, enemy tecnique, reciever vitality
# Know duration 
func begin(dir : Vector2, dur  : int) -> void:
	pushDirection = dir.normalized()
	ticksRemaining = dur

func onEnter() -> void:
	movementComponent.directionLocked = true
	animHandler.set("parameters/conditions/move", true)
	animHandler.set("parameters/roll/blend_position",movementComponent.lastDir)
func process(_delta: float) -> void:
	entity.velocity = pushDirection * pushSpeed
	entity.move_and_slide()
	ticksRemaining -= 1
	if ticksRemaining <= 0:
		if movementComponent.inputDirection.is_zero_approx():
			nextState = $"../idle"
		else:
			nextState = $"../move"
func onExit() -> void:
	movementComponent.directionLocked = false
	animHandler.set("parameters/conditions/move", false)
