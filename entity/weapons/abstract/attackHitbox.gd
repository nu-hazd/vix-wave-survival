class_name WeaponHitbox
extends Area2D
@warning_ignore("unused_signal")
signal parried(stats : EntityStatsComponent, atk : AttackData)
var currentAttack : AttackData

var active: bool = false
var interactedGuards : Array[GuardComponent]

func setAttack(attack: AttackData) -> void:
	currentAttack = attack
func activate() -> void:
	active = true
	interactedGuards.clear()
func deactivate() -> void:
	active = false
