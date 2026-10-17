extends ProgressBar
class_name HealthBar

# Called when the node enters the scene tree for the first time.
func flash() -> void:
	$anims.play("flash")
