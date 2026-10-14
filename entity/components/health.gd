class_name HealthComponent extends Node

signal dead
signal healthChanged(p : int, n : int)
signal damageTaken(amount : int)

const baseMaxHealth : int = 10
var stats : EntityStatsComponent

var health : int  
var invincibilityFrames : int = 0

func setup(sts : EntityStatsComponent)-> void:
	@warning_ignore("integer_division")
	health = baseMaxHealth + sts.vigor / 2
	set_physics_process(false)
func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = newHealth
	if newHealth != prevHealth:
		healthChanged.emit(prevHealth, newHealth)
func _physics_process(_delta: float) -> void:
	invincibilityFrames -= 1
	if invincibilityFrames <= 0:
		set_physics_process(false)
func takeDamage(damageAmount : int) -> void:
	if invincibilityFrames > 0:
		return
	setHealth(max(0, health-damageAmount))
	if health == 0:
		dead.emit()
	else:
		damageTaken.emit(damageAmount)
func setInvincibility(frames : int) -> void:
	invincibilityFrames = max(0, frames)
	set_physics_process(true)
	
	
