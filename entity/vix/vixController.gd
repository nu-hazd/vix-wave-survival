extends ControllerComponent
class_name VixController


func _physics_process(_delta: float) -> void:
	setDirection(Input.get_vector("left","right","up","down"))
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(block):
		requestAction(block)
		return
	if event.is_action_released(block):
		requestAction(unblock)
		return
	for action in [attack0, attack1, dodge]:
		if event.is_action_pressed(action):
			requestAction(action)
