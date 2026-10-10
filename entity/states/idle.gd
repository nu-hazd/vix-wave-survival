extends MovementState


func onEnter() -> void:
	animHandler.set("parameters/conditions/idle", true)
	animHandler.set("parameters/idle/blend_position", entity.velocity.normalized())
	entity.velocity = Vector2.ZERO
func process(_delta : float) -> void:
	if controller.direction:
		nextState = $"../move"
func onExit() -> void:
	animHandler.set("parameters/conditions/idle", false)
