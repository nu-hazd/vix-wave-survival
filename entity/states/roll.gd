extends MovementState
class_name RollState
var baseRollSpeed : int = 500
var baseRollDuration : int = 24

var rollSpeed : int
var rollDirection: Vector2 = Vector2.RIGHT
var ticksRemaining: int = 0


func begin(direction: Vector2) -> void:
	rollDirection = direction.normalized()
	rollSpeed = baseRollSpeed + entity.stats.dexterity*3
	ticksRemaining = baseRollDuration + int(entity.stats.flow / 4.0)


func onEnter() -> void:
	animHandler.set("parameters/conditions/roll", true)
	# If your roll animation uses directional blending:
	animHandler.set(
		"parameters/roll/blend_position",
		rollDirection
	)


func process(_delta: float) -> void:
	entity.velocity = rollDirection * rollSpeed
	entity.move_and_slide()
	ticksRemaining -= 1
	if ticksRemaining <= 0:
		if movementComponent.inputDirection.is_zero_approx():
			nextState = $"../idle"
		else:
			nextState = $"../move"

func onExit() -> void:
	animHandler.set("parameters/conditions/roll", false)
