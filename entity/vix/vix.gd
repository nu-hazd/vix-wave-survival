extends Entity
class_name Vix

@onready var movement: MovementComponent = $movement

func _process(delta: float) -> void:
	movement.process(delta)
