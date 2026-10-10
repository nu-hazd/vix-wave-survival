extends MovementState


func onEnter() -> void:
	animHandler.set("parameters/conditions/move", true)
func onExit() -> void:
	animHandler.set("parameters/conditions/move", false)
func process(_delta : float) -> void:
	if controller.direction != Vector2.ZERO:
		entity.velocity = controller.direction * ( entity.stats.dexterity * 30 )
		entity.move_and_slide()
		if entity.velocity.x:
			$"../../../sprite".scale.x = sign(entity.velocity.x)
		updateAnimHanlder()
	else:
		nextState = $"../idle"
func updateAnimHanlder() -> void:
	animHandler.set("parameters/move/blend_position", entity.velocity.normalized())
