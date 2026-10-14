class_name EnemyController extends ControllerComponent 

@export var pathfinder: NavigationAgent2D 

@export var enemy : Enemy
var vixReference : Vix

enum FIGHT_STYLE { DEFENSIVE, OFFENSIVE, MOBILE }
enum STATE { IDLE, WANDER, APPROACH, FIGHT}

@export_group("Movement")
@export_range(0 ,20, 1, "prefer_slider") var findPlayerChance : int = 5
@export_range(0, 300, 10, "prefer_slider") var movementInterval : int = 60
@export_range(30, 500, 10, "prefer_slider") var forgetPlayerTime : int = 60
@export_range(0, 500, 10, "prefer_slider") var wanderRadius: int = 150
@export_group("Combat")
@export_range(0, 120, 1,"prefer_slider") var fightSkill : int = 60
@export_range(30, 300, 10, "prefer_slider") var disengageTime : int = 60
@export var fightStyle : FIGHT_STYLE = FIGHT_STYLE.OFFENSIVE

const pathfindUpdateTime : int = 20
var forgetCounter : int
var movementCounter : int
var disengageCounter : int
var pathfindCounter : int
var fightCounter : int

var vixInAggro : bool = false
var vixInFight : bool = false

var currentState : STATE
func _ready() -> void:
	startNavigation.call_deferred()
func startNavigation() -> void:
	await get_tree().physics_frame
	enterWander()

func enterWander() -> void:
	var randomOffset := Vector2(
		randi_range(-wanderRadius, wanderRadius),
		randi_range(-wanderRadius, wanderRadius)
	)
	pathfinder.target_position = enemy.global_position + randomOffset
	if findPlayerChance > randi() % 20:
		pathfinder.target_position = vixReference.global_position
	currentState = STATE.WANDER

func enterIdle() -> void:
	movementCounter = movementInterval
	currentState = STATE.IDLE
	setDirection(Vector2.ZERO)
func enterApproach() -> void: 
		currentState = STATE.APPROACH
		pathfindCounter = 0
		forgetCounter = forgetPlayerTime
func enterFight() -> void:
	fightCounter = fightSkill
	setDirection(Vector2.ZERO)
	currentState = STATE.FIGHT
func _physics_process(_delta: float) -> void:
	match currentState:
		STATE.IDLE:
			print("IDLE")
			movementCounter -= 1
			if movementCounter <= 0:
				enterWander()
		STATE.WANDER:
			print("WANDER")
			if pathfinder.is_navigation_finished():
				enterIdle()
			elif not pathfinder.is_target_reachable():
				enterIdle()
			else:
				setDirection(enemy.global_position.direction_to(pathfinder.get_next_path_position()))
		STATE.APPROACH:
			print("APPROACH")
			if not vixInAggro:
				forgetCounter -= 1
			if forgetCounter <= 0:
				enterIdle()
			else:
				pathfindCounter -= 1
				if pathfindCounter <= 0:
					pathfinder.target_position = vixReference.global_position
					pathfindCounter = pathfindUpdateTime
					var nextPosition := pathfinder.get_next_path_position()
					if pathfinder.is_target_reachable():
						setDirection(enemy.global_position.direction_to(nextPosition))
					else:
						enterIdle()
		STATE.FIGHT:
			print("FIGHT")
			if not vixInFight:
				disengageCounter -= 1
				if disengageCounter <= 0:
					enterApproach()
			determineFightAction()


func determineFightAction() -> void:
	fightCounter += 1
	if fightCounter < fightSkill: 
		return
	pathfinder.target_position = vixReference.global_position
	setDirection(enemy.global_position.direction_to(pathfinder.get_next_path_position()))
	match fightStyle:
		FIGHT_STYLE.OFFENSIVE:
			if randi() % 100 > 80:
				setDirection(-(enemy.global_position.direction_to(pathfinder.get_next_path_position())))
			var actionDecision : int = randi() % 100
			if enemy.coordinator.guard.isGuarding() && actionDecision < 80:
				requestAction("unblock")
			if actionDecision < 10:
				if enemy.coordinator.canBlock():
					requestAction("block")
			elif actionDecision < 20:
				requestAction("dodge")
			else:
				requestAction("attack0")
		FIGHT_STYLE.DEFENSIVE:
			pass
		FIGHT_STYLE.MOBILE:
			pass
	fightCounter = 0

func _on_fight_body_entered(body: Node2D) -> void:
	if body is  Vix:
		vixInFight = true
		enterFight()
func _on_fight_body_exited(body: Node2D) -> void:
	if body is  Vix:
		disengageCounter = disengageTime
		vixInFight = false
func _on_aggro_body_entered(body: Node2D) -> void:
	if body is  Vix:
		vixInAggro = true
		enterApproach()
func _on_aggro_body_exited(body: Node2D) -> void:
	if body is  Vix:
		forgetCounter = forgetPlayerTime
		vixInAggro = false
