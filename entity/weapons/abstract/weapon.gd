class_name Weapon
extends Node2D

var stats : EntityStatsComponent

signal addMovementMultiplier(n : StringName, factor : float)
signal removeMovementMultiplier(n : StringName)

signal attackStarted(id: StringName)
signal attackFinished(id: StringName)

signal attackStateChanged(
	oldState: ATTACK_STATE,
	newState: ATTACK_STATE
)


enum ATTACK_STATE {
	IDLE,
	STARTUP,
	ACTIVE,
	RECOVERY
}


@onready var animationPlayer: AnimationPlayer = $attacks
@export var hitbox : WeaponHitbox 


@export var attacks: Array[AttackData] = []


var attackLookup: Dictionary[StringName, AttackData] = {}

var currentAttack: AttackData
var state: ATTACK_STATE = ATTACK_STATE.IDLE

var ticksRemaining: int = 0



func _ready() -> void:
	buildAttackLookup()


func _physics_process(_delta: float) -> void:
	if state == ATTACK_STATE.IDLE:
		return
	ticksRemaining -= 1
	if ticksRemaining <= 0:
		advanceAttackState()


# -------------------------------------------------------------------
# Attack lookup
# -------------------------------------------------------------------

func buildAttackLookup() -> void:
	attackLookup.clear()
	for attack in attacks:
		if attack == null:
			continue

		if attack.id== &"":
			push_warning("Weapon contains an AttackData resource with no id.")
			continue

		if attackLookup.has(attack.id):
			push_warning(
				"Duplicate id found: " + str(attack.id)
			)
			continue

		attackLookup[attack.id] = attack


func hasAttack(id: StringName) -> bool:
	return attackLookup.has(id)


# -------------------------------------------------------------------
# Public interface
# -------------------------------------------------------------------
func setup(layer : int, sts : EntityStatsComponent):
	hitbox.set_collision_layer_value(layer, true)
	stats = sts
func use(id: StringName) -> bool:
	if not attackLookup.has(id):
		push_warning(
			"Weapon does not contain attack: " + str(id)
		)
		return false
	var attack: AttackData = attackLookup[id]
	if not validateAttack(attack):
		return false
	currentAttack = attack
	attackStarted.emit(currentAttack.id)
	enterStartup()
	return true


func canUse() -> bool:
	return state == ATTACK_STATE.IDLE


func isAttacking() -> bool:
	return state != ATTACK_STATE.IDLE


func getCurrentAttack() -> AttackData:
	return currentAttack


func getState() -> ATTACK_STATE:
	return state


func getMovementMultiplier() -> float:
	if currentAttack == null:
		return 1.0
	return currentAttack.movementMultiplier


# -------------------------------------------------------------------
# Attack state machine
# -------------------------------------------------------------------

func advanceAttackState() -> void:
	match state:
		ATTACK_STATE.STARTUP:
			enterActive()

		ATTACK_STATE.ACTIVE:
			enterRecovery()

		ATTACK_STATE.RECOVERY:
			enterIdle()


func enterStartup() -> void:
	setState(ATTACK_STATE.STARTUP)
	addMovementMultiplier.emit("weapon",getMovementMultiplier())
	ticksRemaining = currentAttack.startup.durationTicks
	playPhase(currentAttack.startup)

func enterActive() -> void:
	setState(ATTACK_STATE.ACTIVE)
	ticksRemaining = currentAttack.active.durationTicks
	hitbox.setAttack(currentAttack)
	hitbox.activate()
	playPhase(currentAttack.active)

func enterRecovery() -> void:
	setState(ATTACK_STATE.RECOVERY)
	ticksRemaining = currentAttack.recovery.durationTicks
	hitbox.deactivate()
	playPhase(currentAttack.recovery)


func enterIdle() -> void:
	var finishedid : StringName = currentAttack.id
	removeMovementMultiplier.emit("weapon" )
	hitbox.deactivate()
	currentAttack = null
	ticksRemaining = 0
	setState(ATTACK_STATE.IDLE)
	attackFinished.emit(finishedid)


func setState(newState: ATTACK_STATE) -> void:
	if newState == state:
		return
	var oldState := state
	state = newState
	attackStateChanged.emit(oldState, newState)
# -------------------------------------------------------------------
# Animation
# -------------------------------------------------------------------
func playPhase(phase: AttackPhase) -> void:
	if phase == null:
		push_error("Attempted to play a null AttackPhase.")
		return

	if phase.animationName == &"":
		push_error("AttackPhase has no animationName.")
		return

	if not animationPlayer.has_animation(phase.animationName):
		push_error(
			"Weapon AnimationPlayer is missing animation: "
			+ str(phase.animationName)
		)
		return

	var animation := animationPlayer.get_animation(
		phase.animationName
	)

	var desiredDuration: float = (
		float(phase.durationTicks)
		/ Engine.physics_ticks_per_second
	)

	if desiredDuration <= 0.0:
		push_error(
			"AttackPhase duration must be greater than zero."
		)
		return

	var playbackSpeed: float = (
		animation.length
		/ desiredDuration
	)

	animationPlayer.play(
		phase.animationName,
		-1.0,
		playbackSpeed
	)


# -------------------------------------------------------------------
# Validation
# -------------------------------------------------------------------

func validateAttack(attack: AttackData) -> bool:
	if attack.startup == null:
		push_error(
			str(attack.id)
			+ " has no startup AttackPhase."
		)
		return false

	if attack.active == null:
		push_error(
			str(attack.id)
			+ " has no active AttackPhase."
		)
		return false

	if attack.recovery == null:
		push_error(
			str(attack.id)
			+ " has no recovery AttackPhase."
		)
		return false

	return true
