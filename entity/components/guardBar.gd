class_name GuardBar extends TextureProgressBar


func update(newVal : int) -> void:
	if newVal != value:
		self.value = newVal
		$effects.play("pulse")
func guardBroken() -> void:
	self.value = max_value
	$effects.play("break")
func recoverGuard() -> void:
	$effects.play("recover")
	var tween := create_tween()
	tween.tween_property(
		self,
		"value",
		0.0,
		0.25
	)
