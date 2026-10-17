class_name HealthComponent extends Node
@export var healthBar : HealthBar

signal dead
signal healthChanged(p : int, n : int)
signal damageTaken(amount : int)

const baseMaxHealth : int = 4
var stats : EntityStatsComponent

var maxHealth : int
var health : int  
var invincibilityFrames : int = 0

func setup(sts : EntityStatsComponent)-> void:
	@warning_ignore("integer_division")
	maxHealth = baseMaxHealth + sts.vigor / 2
	health = maxHealth
	set_physics_process(false)
func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = newHealth
	healthBar.value =  ( health / float(maxHealth) ) * 100
	if newHealth != prevHealth:
		healthChanged.emit(prevHealth, newHealth)
func _physics_process(_delta: float) -> void:
	invincibilityFrames -= 1
	if invincibilityFrames <= 0:
		set_physics_process(false)
func takeDamage(damageAmount : int) -> void:
	if invincibilityFrames > 0:
		return
	$hurt.play()
	healthBar.flash()
	setHealth(max(0, health-damageAmount))
	if health == 0:
		dead.emit()
	else:
		damageTaken.emit(damageAmount)
func setInvincibility(frames : int) -> void:
	invincibilityFrames = max(0, frames)
	set_physics_process(true)
	
	
