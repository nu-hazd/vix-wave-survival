extends MovementState


func onEnter() -> void:
	animHandler.set("parameters/conditions/move", true)
func onExit() -> void:
	animHandler.set("parameters/conditions/move", false)
func process(_delta : float) -> void:
	if movementComponent.inputDirection != Vector2.ZERO:
		entity.velocity = movementComponent.inputDirection * ( entity.stats.dexterity * 5 ) * movementComponent.getCurrentMultiplier()
		entity.move_and_slide()
	else:
		nextState = $"../idle"
func updateAnimHanlder() -> void:
	animHandler.set("parameters/move/blend_position", entity.velocity.normalized())
