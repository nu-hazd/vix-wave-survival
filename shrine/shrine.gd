extends Node2D
class_name Shrine
signal exitShrine

@onready var himeko: Himeko = $himeko
@onready var exitArea: Area2D = $exitArea
@onready var camera : Camera2D = $Camera2D
@onready var enterpos: Marker2D = $enterpos
var vixRef: Vix
var currentNight : int = 0
var transitioning : bool = false
# Called when the node enters the scene tree for the first time.

func enterShrine (_code : WaveSurvival.EXIT_CODE, nightNum : int) -> void:
	$music.play()
	currentNight = nightNum
	self.visible = true
	vixRef.camera.enabled = false
	camera.enabled = true
	self.add_child(vixRef)
	vixRef.disableCombat()
	vixRef.global_position = enterpos.global_position

func reset() -> void:
	pass



func _exit_to_survival() -> void:
	$music.stop()
	if vixRef.get_parent() == self:
		remove_child(vixRef)
	exitShrine.emit()


func _on_exit_area_body_entered(body: Node2D) -> void:

	if body != vixRef:
		return
	if transitioning:
		return
	transitioning = true
	$transition.start()
	# Wait until PhysicsServer has finished this query.
	call_deferred("_exit_to_survival")


func _on_transition_timeout() -> void:
	transitioning = false


func _on_heal_body_entered(body: Node2D) -> void:
	if body is Vix:
		if body.coordinator.health.health < body.coordinator.health.maxHealth:
			body.coordinator.health.setHealth(body.coordinator.health.maxHealth) 
			$himeko/heal/fx.play()
