class_name Weapon extends Node2D 

@export var user : Entity
@export var cooldown : float = 1.0
var onCooldown : bool = false

func _ready() -> void:
	$cooldown.wait_time = cooldown
	setUp()
func setUp() -> void:
	pass
func use() -> void:
	pass
func canUse() -> bool:
	return not onCooldown

func _on_cooldown_timeout() -> void:
	onCooldown = false
