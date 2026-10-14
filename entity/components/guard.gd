class_name GuardComponent extends Area2D

var health : HealthComponent
var stats : EntityStatsComponent

signal guardBroken
signal attackBlocked
signal attackParried

signal addMovementMultiplier(n : StringName, factor : float)
signal removeMovementMultiplier(n : StringName)

const baseMaxGuard : int = 10
const baseParryWindow : int = 6
const baseGuardBreakDuration : int = 60
const baseGuardDownPenalty : int = 30
const baseBlockingMovementMultiplier : float = 0.30
const baseRecoveryMovementMultiplier : float = 0.50

var maxGuard : int
var parryWindow : int # Frames
var guardBreakDuration : int
var guardDownPenalty : int
var blockingMovementMultiplier : float
var recoveryMovementMultiplier : float

var succesfulParry : bool = false
var currentGuard : int
var guardBreakTimer : int 

func setup(mask : int , sts : EntityStatsComponent, hlth : HealthComponent) -> void:
	stats = sts
	health = hlth
	set_collision_mask_value(mask, true) 
	currentGuard = 0
	guardBreakTimer = 0
	@warning_ignore_start("integer_division")
	maxGuard = baseMaxGuard + stats.vigor / 2
	parryWindow = baseParryWindow + stats.flow / 5
	guardBreakDuration = baseGuardBreakDuration - stats.vigor / 5
	guardDownPenalty = baseGuardDownPenalty - stats.dexterity / 5
	blockingMovementMultiplier = baseBlockingMovementMultiplier + 0.45 * (stats.dexterity / 100.0 )
	recoveryMovementMultiplier = baseRecoveryMovementMultiplier + 0.40 * ( stats.dexterity / 100.0 ) 
	@warning_ignore_restore("integer_division")


enum STATES { OFF, BLOCK, PARRY, BROKEN, STANDBY }
var state : STATES 
signal stateChanged(old : STATES, new : STATES)

func _ready() -> void:
	setState(STATES.STANDBY)

func setState(newState : STATES) -> void:
	if newState != state:
		stateChanged.emit(state,newState)
		state = newState
		$stateAnimHanlder.set("parameters/blend_position", state)
	match state:
		STATES.BLOCK, STATES.PARRY:
			addMovementMultiplier.emit("block", blockingMovementMultiplier)
		STATES.OFF:
			addMovementMultiplier.emit("recovery", recoveryMovementMultiplier)
			removeMovementMultiplier.emit("block")
		STATES.STANDBY, STATES.BROKEN:
			removeMovementMultiplier.emit("block")
			removeMovementMultiplier.emit("recovery")
		
			
func getState() -> STATES:
	return state
func blockAttack( hitbox : WeaponHitbox) -> void:
	increaseCurrentGuard(hitbox.currentAttack.guardDamage)
	attackBlocked.emit()
	#TODO: push logic
func increaseCurrentGuard(amount : int ) -> void:
	currentGuard = min(maxGuard, currentGuard + amount)
	if currentGuard == maxGuard:
		breakGuard()
func breakGuard() -> void:
	setState(STATES.BROKEN)
	guardBroken.emit()

func block() -> void:
	if state == STATES.STANDBY:
		setState(STATES.PARRY)
		countFrames = true
		frameCounter = parryWindow
func unblock() -> void:
	if state == STATES.BLOCK or state == STATES.PARRY:
		if succesfulParry:
			setState(STATES.STANDBY)
			succesfulParry = false
		else:
			setState(STATES.OFF)
			countFrames = true
			frameCounter = guardDownPenalty

func isGuarding() -> bool:
	return state == STATES.PARRY or state == STATES.BLOCK
func nextState(): 
	match state:
		STATES.OFF:
			setState(STATES.STANDBY)
		STATES.PARRY:
			setState(STATES.BLOCK)
var countFrames : bool = false
var frameCounter : int
var hitboxesInGuard : Array[WeaponHitbox] = []
func _physics_process(_delta: float) -> void:
	if countFrames:
		frameCounter -= 1
		if frameCounter == 0:
			countFrames = false
			nextState()
	for hitbox in hitboxesInGuard:
		if hitbox.active and not hitbox.interactedGuards.has(self):
			recieveAttack(hitbox)
		

func recieveAttack(hitbox : WeaponHitbox) -> void:
	match state:
			STATES.STANDBY:
				health.takeDamage(hitbox.currentAttack.physicalDamage)
			STATES.OFF:
				health.takeDamage(hitbox.currentAttack.physicalDamage)
			STATES.BLOCK:
				blockAttack(hitbox)
			STATES.PARRY:
				parryAttack(hitbox)
	hitbox.interactedGuards.append(self)
func parryAttack(hitbox : WeaponHitbox) -> void:
	hitbox.parried.emit(stats, hitbox.currentAttack)
	attackParried.emit()
	succesfulParry = true

func weaponParried(opposingEntityStats : EntityStatsComponent, attackInfo : AttackData) -> void:
	increaseCurrentGuard(
		int(attackInfo.guardDamage / 2.0
		* (1.0 + opposingEntityStats.flow / 50.0)))

func _on_area_entered(area: Area2D) -> void:
	if area is WeaponHitbox:
		hitboxesInGuard.append(area)
func _on_area_exited(area: Area2D) -> void:
	if area is WeaponHitbox:
		hitboxesInGuard.erase(area)
