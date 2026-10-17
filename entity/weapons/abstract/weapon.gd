class_name Weapon
extends Node2D


var stats: EntityStatsComponent


signal addMovementMultiplier(n: StringName, factor: float)
signal removeMovementMultiplier(n: StringName)

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
@onready var sfxPlayers : Array[AudioStreamPlayer2D] = [$"0", $"1"]

@export var hitbox: WeaponHitbox
@export var hitboxDisplay : Polygon2D
@export_group("Attack Chains")
@export var attackChain0: Array[AttackData] = []
@export var attackChain1: Array[AttackData] = []


var currentAttack: AttackData
var currentAction: StringName = &""
var currentChainIndex: int = 0

var queuedAction: StringName = &""

var state: ATTACK_STATE = ATTACK_STATE.IDLE
var ticksRemaining: int = 0

func _ready() -> void:
	self.visible = false

func _physics_process(_delta: float) -> void:
	if state == ATTACK_STATE.IDLE:
		return

	ticksRemaining -= 1

	if ticksRemaining <= 0:
		advanceAttackState()


# -------------------------------------------------------------------
# Setup
# -------------------------------------------------------------------

func setup(layer: int, sts: EntityStatsComponent) -> void:
	stats = sts

	hitbox.set_collision_layer_value(layer, true)
	hitbox.deactivate()


# -------------------------------------------------------------------
# Public interface
# -------------------------------------------------------------------

func use(action: StringName) -> bool:
	if not canUse(action):
		return false
	# No attack is currently happening.
	if state == ATTACK_STATE.IDLE:
		startChain(action)
		return true
	# An attack is already happening, so remember the input.
	queuedAction = action
	return true


func canUse(action: StringName) -> bool:
	var chain := getAttackChain(action)
	if chain.is_empty():
		return false
	# Any valid attack may begin while idle.
	if state == ATTACK_STATE.IDLE:
		return true
	# Only buffer one future attack.
	if queuedAction != &"":
		return false
	# Do not accept combo inputs during startup by default.
	if state == ATTACK_STATE.STARTUP:
		return false
	# If continuing the same chain, make sure another attack exists.
	if action == currentAction:
		return currentChainIndex + 1 < chain.size()

	# Changing to the other attack chain begins that chain from index 0.
	return true


func cancel() -> void:
	if state == ATTACK_STATE.IDLE:
		return
	self.visible = false
	hitbox.deactivate()
	animationPlayer.stop()

	queuedAction = &""
	currentAction = &""
	currentChainIndex = 0
	currentAttack = null
	ticksRemaining = 0

	removeMovementMultiplier.emit(&"weapon")
	setState(ATTACK_STATE.IDLE)


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
# Attack chains
# -------------------------------------------------------------------
func getAttackChain(action: StringName) -> Array[AttackData]:
	match action:
		ControllerComponent.attack0:
			return attackChain0
		ControllerComponent.attack1:
			return attackChain1
	return []
func startChain(action: StringName) -> void:
	var chain := getAttackChain(action)
	if chain.is_empty():
		return
	currentAction = action
	currentChainIndex = 0
	startAttack(chain[currentChainIndex])


func continueChain(action: StringName) -> void:
	var chain := getAttackChain(action)
	if chain.is_empty():
		enterIdle()
		return
	# Continue the chain currently being used.
	if action == currentAction:
		currentChainIndex += 1
		if currentChainIndex >= chain.size():
			enterIdle()
			return
	# Switching attack buttons starts the other chain.
	else:
		currentAction = action
		currentChainIndex = 0
	startAttack(chain[currentChainIndex])


func startAttack(attack: AttackData) -> void:
	if attack == null:
		push_error("Weapon attempted to start a null AttackData.")
		enterIdle()
		return
	if not validateAttack(attack):
		enterIdle()
		return
	currentAttack = attack
	print("Atk: %s Is unlbock: %s" % [currentAttack.id,currentAttack.unblockable])
	attackStarted.emit(currentAttack.id)
	enterStartup()


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
			finishCurrentAttack()
func enterStartup() -> void:
	self.visible = true
	setState(ATTACK_STATE.STARTUP)
	hitbox.deactivate()
	addMovementMultiplier.emit(
		&"weapon",
		getMovementMultiplier()
	)
	ticksRemaining = currentAttack.startup.durationTicks
	playPhase(currentAttack.startup)
	if currentAttack.pureGuard:
		hitboxDisplay.color = Color.GREEN
	elif currentAttack.unblockable:
		hitboxDisplay.color = Color.LIGHT_CORAL
	else:
		hitboxDisplay.color = Color.WEB_GRAY
func enterActive() -> void:
	var useSfx : int = currentAttack.sfx
	sfxPlayers[useSfx].pitch_scale = randf_range(0.90,1.10)
	sfxPlayers[useSfx].play()
	setState(ATTACK_STATE.ACTIVE)
	ticksRemaining = currentAttack.active.durationTicks
	hitbox.setAttack(currentAttack)
	hitbox.activate()
	playPhase(currentAttack.active)
	if currentAttack.pureGuard:
		hitboxDisplay.color = Color.GREEN
	elif currentAttack.unblockable:
		hitboxDisplay.color = Color.RED
	else:
		hitboxDisplay.color = Color.WHITE
func enterRecovery() -> void:
	setState(ATTACK_STATE.RECOVERY)
	ticksRemaining = currentAttack.recovery.durationTicks
	hitbox.deactivate()
	playPhase(currentAttack.recovery)
	hitboxDisplay.color = Color.WEB_GRAY
func finishCurrentAttack() -> void:
	var finishedId := currentAttack.id
	hitbox.deactivate()
	attackFinished.emit(finishedId)
	if queuedAction != &"":
		var nextAction := queuedAction
		queuedAction = &""
		continueChain(nextAction)
		return
	enterIdle()
func enterIdle() -> void:
	removeMovementMultiplier.emit(&"weapon")
	hitbox.deactivate()
	queuedAction = &""
	currentAction = &""
	currentChainIndex = 0
	currentAttack = null
	ticksRemaining = 0
	self.visible = false
	setState(ATTACK_STATE.IDLE)
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
	var desiredDuration := (
		float(phase.durationTicks)
		/ Engine.physics_ticks_per_second
	)
	if desiredDuration <= 0.0:
		push_error(
			"AttackPhase duration must be greater than zero."
		)
		return

	var playbackSpeed := (
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
