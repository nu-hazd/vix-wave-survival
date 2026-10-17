extends MovementState
const baseMoveSpeed : int = 75

func onEnter() -> void:
	animHandler.set("parameters/conditions/move", true)
func onExit() -> void:
	animHandler.set("parameters/conditions/move", false)
func process(_delta : float) -> void:
	if movementComponent.inputDirection != Vector2.ZERO:
		entity.velocity = movementComponent.inputDirection * movementComponent.getCurrentMultiplier() * baseMoveSpeed *  (1 + entity.stats.dexterity / 100.0 ) 
		entity.move_and_slide()
	else:
		nextState = $"../idle"
func updateAnimHanlder() -> void:
	animHandler.set("parameters/move/blend_position", entity.velocity.normalized())
