class_name Entity extends CharacterBody2D

signal dead
signal healthChanged(oldHealth, newHealth)

@export var maxHealth : int = 100
@export var moveSpeed : int = 300
@export var attack : int = 1
@export var defense : int = 1

@export var iFrameDuration : float = 0.25
var health : int  
var iFrames : float = 0

func getMaxHealth() -> int:
	return maxHealth
func getHealth() -> int:
	return health
func getMoveSpeed() -> int:
	return moveSpeed
func getAttack() -> int:
	return attack
func getDefense() -> int:
	return defense

func setMaxHealth(newMaxHP : int) -> void:
	maxHealth = newMaxHP
func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = newHealth
	if newHealth != prevHealth:
		healthChanged.emit(prevHealth, newHealth)
func setMoveSpeed(newMoveSpeed : int) -> void:
	moveSpeed = newMoveSpeed
func setAttack(newAttack : int) -> void:
	attack = max(1, newAttack)
func setDefense(newDefense : int) -> void:
	defense = max(1, newDefense)

func takeDamage(damageAmount : int) -> void:
	setHealth(max(0, health-damageAmount))
	if health == 0:
		dead.emit()
	
 
