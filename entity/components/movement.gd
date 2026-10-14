class_name MovementComponent extends StateMachine
var entity : Entity
@onready var anim_hanlder: AnimationTree = $animHanlder
@onready var rollState : RollState = $states/roll
@onready var push: PushState = $states/push

var lastDir : Vector2 = Vector2.RIGHT 
var directionLocked : bool = false
var movementMultipliers : Dictionary[StringName,float] = {}
var inputDirection : Vector2 = Vector2.ZERO
var rollCooldown : int = 0
var weapon : Weapon

func setup(ent : Entity, wpn : Weapon ) -> void:
	self.entity = ent
	for movementState in $states.get_children() as Array[MovementState]:
		movementState.entity = ent
		movementState.animHandler = anim_hanlder
		movementState.movementComponent = self
	weapon = wpn
	weapon.attackStarted.connect(lockDirection)
	weapon.attackFinished.connect(unlockDirection)
	super.ready()

func process(delta) -> void:
	if not directionLocked:
		if not entity.velocity.is_zero_approx():
			lastDir = entity.velocity.normalized()
			if not is_zero_approx(lastDir.x):
				entity.sprite.scale.x = sign(lastDir.x)
		currentState.updateAnimHanlder()
		weapon.rotation = lastDir.angle()
	rollCooldown = max(0, rollCooldown-1)
	super.process(delta)
func beginPush(dir : Vector2, dur : int) -> void:
	push.begin(dir,dur)
	setCurrentState(push)
func lockDirection(_s : StringName) -> void:
	directionLocked = true
func unlockDirection(_s : StringName) -> void:
	directionLocked = false

func requestRoll(direction: Vector2) -> bool:
	if currentState != $states/idle and currentState != $states/move or rollCooldown > 0:
		return false
	var rollDirection := direction
	if rollDirection.is_zero_approx():
		rollDirection = lastDir
	rollState.begin(rollDirection)
	setCurrentState(rollState)
	rollCooldown = rollState.baseRollDuration*3
	return true

func setStunState() -> void:
	pass
func setDeathState() -> void:
	setCurrentState($states/death)
func setMovementMultiplier(id : StringName, val : float) -> void:
	movementMultipliers[id] = val
func removeMovementMultiplier(id : StringName) -> void:
	if movementMultipliers.has(id):
		movementMultipliers.erase(id)
func getCurrentMultiplier() -> float:
	var maxMultiplier : float = 1.0
	for key in movementMultipliers.keys():
		maxMultiplier = min(maxMultiplier, movementMultipliers[key])
	return maxMultiplier
