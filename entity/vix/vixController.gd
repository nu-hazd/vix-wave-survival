extends ControllerComponent

signal lastNonZeroDirChanged(newDir : Vector2)
var lastNonZeroDir : Vector2 = Vector2.RIGHT

func _process(_delta: float) -> void:
	direction = Input.get_vector("left","right","up","down")
	if direction:
		lastNonZeroDir = direction
		lastNonZeroDirChanged.emit(lastNonZeroDir)
	if Input.is_action_just_pressed("attack"):
		setAction("attack")
