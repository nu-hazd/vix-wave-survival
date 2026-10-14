extends MovementState
class_name DeathState

func onEnter() -> void:
	animHandler.set("parameters/conditions/dead", true)
	updateAnimHanlder()
	entity.velocity = Vector2.ZERO
func process(_delta : float) -> void:
	pass
func onExit() -> void:
	animHandler.set("parameters/conditions/dead", false)
func updateAnimHanlder() -> void:
	animHandler.set("parameters/idle/blend_position", movementComponent.lastDir)
