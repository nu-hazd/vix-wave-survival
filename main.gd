extends Node

@export var vixScene : PackedScene
var vix : Vix 
@onready var waveSurvival: WaveSurvival = $mode/WaveSurvival
@onready var shrine: Shrine = $mode/Shrine
@onready var ui: GlobalUI = $mainUI/ui


var currentNight : int = -1
var nightDataPool : Array[Array] = [
	[preload("res://survival/Night/nightOne/0.tres")],
	[preload("res://survival/Night/nightTwo/0.tres")],	
	[preload("res://survival/Night/nightThree/0.tres")],	
	[preload("res://survival/Night/nightFour/0.tres")],	
	[preload("res://survival/Night/nightFive/0.tres")],	
	[preload("res://survival/Night/nightSix/0.tres")],	
	[preload("res://survival/Night/nightSeven/0.tres")],	
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode =  Input.MOUSE_MODE_CAPTURED
	$menuMusic.play()
	vix = vixScene.instantiate()
	shrine.vixRef = vix
	waveSurvival.vix = vix
	ui.exitGame.connect(quitGame)
	ui.startGame.connect(startGame)
	shrine.exitShrine.connect(enterWaveSurvival)
	waveSurvival.exit.connect(enterShrine)
func enterWaveSurvival() -> void:
	$mainUI/ui/fade.play("fadeOUT")
	await $mainUI/ui/fade.animation_finished
	waveSurvival.startNight(currentNight,nightDataPool[currentNight].pick_random())
	shrine.camera.enabled = false
	$mainUI/ui/fade.play("fadeIN")
func enterShrine(code : WaveSurvival.EXIT_CODE, points : int) -> void:
	currentNight +=1
	waveSurvival.set_physics_process(false)
	$mainUI/ui/fade.play("fadeOUT")
	await $mainUI/ui/fade.animation_finished
	$mainUI/ui/menu.hide()
	if vix.get_parent() == waveSurvival:
		waveSurvival.remove_child(vix)
	shrine.enterShrine(code, currentNight)
	$mainUI/ui/fade.play("fadeIN")
	if code == WaveSurvival.EXIT_CODE.LOSE:
		get_tree().change_scene_to_file("res://lose_screen.tscn")
		
	
func startGame() -> void:
	$menuMusic.stop()
	enterShrine(WaveSurvival.EXIT_CODE.NIGHT_OVER, 0)
func exitGame() -> void:
	shrine.reset()
	ui.setScreen($mainUI/ui/menu)
func quitGame() -> void:
	# save?
	get_tree().quit(Error.OK)
