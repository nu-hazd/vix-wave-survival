extends Control
class_name GlobalUI

signal startGame
signal exitGame
@export var currentScreen : Control 

func _ready() -> void:
	$menu/main/VBoxContainer/start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pause() -> void:
	$pause.visible = true
	Engine.time_scale = 0.0
func unpause() -> void:
	$pause.visible = false
	Engine.time_scale = 1.0

func buttonPressed(id : StringName) -> void:
	match id:
		"start":
			$menu/main/VBoxContainer/start.disabled = true
			startGame.emit()
		"quit":
			exitGame.emit()


func setScreen(scr : Panel) -> void:
	currentScreen.hide()
	currentScreen = scr
	currentScreen.show()
