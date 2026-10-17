class_name GuardComponent extends Area2D
@export var guardBar : GuardBar

var health : HealthComponent
var stats : EntityStatsComponent

signal guardBroken(duration : int)
signal push(dir: Vector2, dur: int)
signal attackBlocked(str : int)
signal attackParried(str : int)
signal addMovementMultiplier(n : StringName, factor : float)
signal removeMovementMultiplier(n : StringName)

const combatTagCounterDuration : int = 300 
const baseMaxGuard : int = 5
const baseParryWindow : int = 10
const baseGuardBreakDuration : int = 120
const baseGuardDownPenalty : int = 30
const baseBlockingMovementMultiplier : float = 0.25
const baseRecoveryMovementMultiplier : float = 0.50

var maxGuard : int
var parryWindow : int # Frames
var guardBreakDuration : int
var guardDownPenalty : int
var blockingMovementMultiplier : float
var recoveryMovementMultiplier : float

var currentCombatTag : int = 0
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
	guardBar.max_value = maxGuard
	parryWindow = baseParryWindow + stats.flow / 5
	guardBreakDuration = baseGuardBreakDuration - stats.vigor / 5
	guardDownPenalty = baseGuardDownPenalty - stats.dexterity / 5
	blockingMovementMultiplier = baseBlockingMovementMultiplier + 0.25 * (stats.dexterity / 100.0 )
	recoveryMovementMultiplier = baseRecoveryMovementMultiplier + 0.25 * ( stats.dexterity / 100.0 ) 
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
	var particleDir := hitbox.global_position.direction_to(global_position)
	$particles.global_rotation = particleDir.angle() 
	$effects.play("block")
	$block.pitch_scale = randf_range(0.95,1.05)
	$block.play()
	attackBlocked.emit(max(1, stats.vigor - hitbox.currentAttack.guardDamage*1.5))
	alterCurrentGuard(hitbox.currentAttack.guardDamage)
	push.emit(-(self.global_position.direction_to(hitbox.global_position)), max(10, hitbox.currentAttack.knockback - stats.vigor) )

func alterCurrentGuard(amount : int ) -> void:
	currentGuard = clamp(currentGuard + amount,0, maxGuard)
	guardBar.update( currentGuard )
	if currentGuard == maxGuard:
		breakGuard()
func breakGuard() -> void:
	setState(STATES.BROKEN)
	$break.play()
	guardBar.guardBroken()
	guardBroken.emit(guardBreakDuration)
func recoverGuard() -> void:
	currentGuard = 0
	guardBar.recoverGuard()
	setState(STATES.STANDBY)
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
	currentCombatTag = max(0, currentCombatTag - 1)
	if currentCombatTag == 0 and currentGuard > 0:
		alterCurrentGuard(-1)

func recieveAttack(hitbox : WeaponHitbox) -> void:
	currentCombatTag = combatTagCounterDuration
	if hitbox.currentAttack.pureGuard:
		if health.invincibilityFrames <= 0:
			alterCurrentGuard(hitbox.currentAttack.guardDamage)
	elif hitbox.currentAttack.unblockable:
		if health.invincibilityFrames <= 0:
			health.takeDamage(hitbox.currentAttack.physicalDamage)
	else:
		match state:
			STATES.STANDBY:
				health.takeDamage(hitbox.currentAttack.physicalDamage)
			STATES.OFF:
				health.takeDamage(hitbox.currentAttack.physicalDamage)
			STATES.BLOCK:
				blockAttack(hitbox)
			STATES.PARRY:
				parryAttack(hitbox)
			STATES.BROKEN:
				health.takeDamage(hitbox.currentAttack.physicalDamage * 2)
				push.emit(-(self.global_position.direction_to(hitbox.global_position)), max(20, (hitbox.currentAttack.knockback)) )
	hitbox.interactedGuards.append(self)
func parryAttack(hitbox : WeaponHitbox) -> void:
	var particleDir := hitbox.global_position.direction_to(global_position)
	$particles.global_rotation = particleDir.angle() 
	$parry.pitch_scale = randf_range(.95,1.05)
	$effects.play("parry")
	$parry.play()
	attackParried.emit(hitbox.currentAttack.guardDamage)
	hitbox.parried.emit(stats, hitbox.currentAttack)
	push.emit(-(self.global_position.direction_to(hitbox.global_position)), max(10, (hitbox.currentAttack.knockback / 2.0) ) - stats.vigor)
	succesfulParry = true

func weaponParried(opposingEntityStats : EntityStatsComponent, attackInfo : AttackData) -> void:
	currentCombatTag = combatTagCounterDuration
	alterCurrentGuard(
		ceil(attackInfo.guardDamage
		* (1.0 + opposingEntityStats.flow / 50.0)))

func _on_area_entered(area: Area2D) -> void:
	if area is WeaponHitbox:
		hitboxesInGuard.append(area)
func _on_area_exited(area: Area2D) -> void:
	if area is WeaponHitbox:
		hitboxesInGuard.erase(area)
