extends MovementState
class_name RollState
var baseRollSpeed : int = 200
var baseRollDuration : int = 20

var rollSpeed : int
var rollDirection: Vector2 = Vector2.RIGHT
var ticksRemaining: int = 0


func begin(direction: Vector2) -> void:
	rollDirection = direction.normalized()
	rollSpeed = baseRollSpeed 
	ticksRemaining = baseRollDuration + int(entity.stats.flow / 5.0)
	entity.coordinator.health.setInvincibility(ticksRemaining)

func onEnter() -> void:
	entity.sprite.modulate  = Color("ffffff50")
	entity.set_collision_mask_value(9, false)
	animHandler.set("parameters/conditions/roll", true)
	animHandler.set("parameters/roll/blend_position",rollDirection)
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
	entity.set_collision_mask_value(9, true)
	entity.sprite.modulate = Color("ffffffff")
	animHandler.set("parameters/conditions/roll", false)
