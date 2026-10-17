extends MovementState
class_name StunState

var ticksRemaining: int = 0

func begin(ticks : int) -> void:
	ticksRemaining = ticks

func onEnter() -> void:
	print(ticksRemaining)
	animHandler.set("parameters/conditions/idle", true)
func process(_delta: float) -> void:
	ticksRemaining -= 1
	if ticksRemaining <= 0:
		if movementComponent.inputDirection.is_zero_approx():
			nextState = $"../idle"
		else:
			nextState = $"../move"
func onExit() -> void:
	print("exited")
	entity.coordinator.guard.recoverGuard()
	animHandler.set("parameters/conditions/idle", false)
