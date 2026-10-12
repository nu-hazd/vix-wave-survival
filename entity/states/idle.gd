extends MovementState


func onEnter() -> void:
	animHandler.set("parameters/conditions/idle", true)
	updateAnimHanlder()
	entity.velocity = Vector2.ZERO
func process(_delta : float) -> void:
	if movementComponent.inputDirection:
		nextState = $"../move"
func onExit() -> void:
	animHandler.set("parameters/conditions/idle", false)
func updateAnimHanlder() -> void:
	animHandler.set("parameters/idle/blend_position", movementComponent.lastDir)
