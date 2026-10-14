class_name AttackData
extends Resource

@export var id: StringName

@export_group("Damage")
@export var physicalDamage : int
@export var guardDamage : int
@export var knockback : int
@export var unblockable : bool = false

@export_group("Phases")
@export var startup : AttackPhase
@export var active : AttackPhase
@export var recovery : AttackPhase

@export_group("Movement")
@export var movementMultiplier : float = 0.5
