class_name Entity extends CharacterBody2D

signal dead
signal healthChanged(oldHealth, newHealth)

@export var stats : EntityStatComponent

@export var iFrameDuration : float = 0.25
var health : int  
var invincible  : bool = false

func _ready() -> void:
	$invincibility.wait_time = iFrameDuration
	health = stats.maxHealth
func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = newHealth
	if newHealth != prevHealth:
		healthChanged.emit(prevHealth, newHealth)

func takeDamage(damageAmount : int) -> void:
	print("damage taken: %f" % damageAmount)
	setHealth(max(0, health-damageAmount))
	if health == 0:
		dead.emit()
	invincible = true
	$invincibility.start()
	
func _on_invincibility_timeout() -> void:
	invincible = false
