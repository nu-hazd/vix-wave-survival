@tool
class_name Coordinator extends Node2D

@export var guard : GuardComponent
@export var movement : MovementComponent
@export var health : HealthComponent
@export var weapon : Weapon
signal entityDied
func _ready() -> void:
	set_physics_process(false)
func start(ent : Entity) -> void:
	var guardMask : int = 1 if (ent is Vix) else 2
	var weaponHitboxLayer : int = 1 if(ent is Enemy) else 2
	movement.setup(ent, weapon)
	health.setup(ent.stats)
	weapon.setup(weaponHitboxLayer, ent.stats)
	guard.setup(guardMask, ent.stats, health)
	guard.push.connect(movement.beginPush)
	health.dead.connect(entityDead)
	weapon.hitbox.parried.connect(guard.weaponParried)
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
			if canAttack(id):	
				weapon.use(id)
		ControllerComponent.attack1:
			if canAttack(id):	
				weapon.use(id)
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

func canAttack(id : StringName) -> bool:
	return weapon.canUse(id) and not guard.isGuarding() and movement.getCurrentStateName() in ["move", "idle"]
func canBlock() -> bool:
	return not weapon.isAttacking() and movement.getCurrentStateName() in ["move", "idle", "push"]
func canDodge() -> bool:
	return not weapon.isAttacking() and movement.getCurrentStateName() in ["idle","move"]
func _physics_process(delta: float) -> void:
	movement.process(delta)

func entityDead() -> void:
	weapon.cancel()
	guard.unblock()
	guard.monitoring = false
	guard.monitorable = false
	movement.setDeathState()
	entityDied.emit()
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var hasWeapon := false
	for child in get_children():
		if child is Weapon:
			hasWeapon = true
	if not hasWeapon:
		warnings.append("Coordinator requires a Weapon child.")
	return warnings
