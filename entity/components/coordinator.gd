class_name Coordinator extends Node2D

@export var guard : GuardComponent
@export var movement : MovementComponent
@export var health : HealthComponent
@export var weapon : Weapon
@export var attack0ID : StringName = "katanaSwingLight"
@export var attack1ID : StringName = "other"
func _ready() -> void:
	set_physics_process(false)
func start(ent : Entity) -> void:
	var guardMask : int = 1 if (ent is Vix) else 2
	var weaponHitboxLayer : int = 1 if(ent is Enemy) else 2
	movement.setup(ent, weapon)
	guard.setup(guardMask, ent.stats, health)
	health.setup(ent.stats)
	weapon.setup(weaponHitboxLayer, ent.stats)
	weapon.addMovementMultiplier.connect(applyMovementMultiplier)
	weapon.removeMovementMultiplier.connect(removeMovementMultiplier)
	guard.addMovementMultiplier.connect(applyMovementMultiplier)
	guard.removeMovementMultiplier.connect(removeMovementMultiplier)
	set_physics_process(true)

func applyMovementMultiplier(id : StringName, val : float) -> void:
	movement.setMovementMultiplier(id, val)
func removeMovementMultiplier(id : StringName) -> void:
	movement.removeMovementMultiplier(id)
	
func directionChanged(newDirection: Vector2) -> void:
	movement.inputDirection = newDirection
func actionRequested(id : StringName) -> void:
	match id:
		ControllerComponent.attack0:
			if canAttack():	
				weapon.use(attack0ID)
		ControllerComponent.attack1:
			if canAttack():	
				weapon.use(attack1ID)
		ControllerComponent.block:
			if canBlock():
				guard.block()
		ControllerComponent.unblock:
			guard.unblock()
		ControllerComponent.dodge:
			if canDodge():
				if guard.isGuarding():
					guard.unblock()
				movement.requestRoll(movement.inputDirection)

func canAttack() -> bool:
	return weapon.canUse() and not guard.isGuarding() and movement.getCurrentStateName() in ["move", "idle"]
func canBlock() -> bool:
	return not weapon.isAttacking() and movement.getCurrentStateName() in ["move", "idle", "push"]
func canDodge() -> bool:
	return not weapon.isAttacking() and movement.getCurrentStateName() in ["idle","move"]
func _physics_process(delta: float) -> void:
	movement.process(delta)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var hasWeapon := false
	for child in get_children():
		if child is Weapon:
			hasWeapon = true
	if not hasWeapon:
		warnings.append("Coordinator requires a Weapon child.")
	return warnings
