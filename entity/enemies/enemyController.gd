class_name EnemyController extends ControllerComponent 

@export var pathfinder: NavigationAgent2D 

@export var enemy : Enemy
var wanderBound : Rect2 = Rect2i(0,0,700,550)
var vixReference : Vix

enum FIGHT_STYLE { DEFENSIVE, OFFENSIVE, MOBILE }
enum STATE { IDLE, WANDER, APPROACH, FIGHT, FLEE}

@export_group("Movement")
@export_range(0 ,20, 1, "prefer_slider") var findPlayerChance : int = 5
@export_range(0, 300, 10, "prefer_slider") var movementInterval : int = 60
@export_range(30, 500, 10, "prefer_slider") var forgetPlayerTime : int = 60
@export_range(0, 500, 10, "prefer_slider") var wanderRadius: int = 150
@export_group("Combat")
@export_range(0, 120, 1,"prefer_slider") var fightSkill : int = 60
@export_range(30, 300, 10, "prefer_slider") var disengageTime : int = 60
@export_range(1,100, 1, "prefer_slider") var attackOnePreference : int = 50
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
var navigationReady: bool = false


func _ready() -> void:
	initializeNavigation.call_deferred()


func initializeNavigation() -> void:
	var navigationMap := pathfinder.get_navigation_map()

	while NavigationServer2D.map_get_iteration_id(navigationMap) == 0:
		await get_tree().physics_frame

	navigationReady = true
	enterIdle()

func getRandomWanderTarget() -> Vector2:
	var desiredTarget := enemy.global_position + Vector2(
		randf_range(-wanderRadius, wanderRadius),
		randf_range(-wanderRadius, wanderRadius)
	)
	# Keep the desired point inside the allowed wandering area.
	desiredTarget.x = clampf(
		desiredTarget.x,
		wanderBound.position.x,
		wanderBound.end.x
	)
	desiredTarget.y = clampf(
		desiredTarget.y,
		wanderBound.position.y,
		wanderBound.end.y
	)
	# Snap water / invalid positions onto nearby navigable terrain.
	return NavigationServer2D.map_get_closest_point(
		pathfinder.get_navigation_map(),
		desiredTarget
	)
func enterWander() -> void:
	pathfinder.target_position = getRandomWanderTarget()
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
	if not navigationReady:
		return
	match currentState:
		STATE.IDLE:
			movementCounter -= 1
			if movementCounter <= 0:
				enterWander()
		STATE.WANDER:
			if pathfinder.is_navigation_finished():
				enterIdle()
			elif not pathfinder.is_target_reachable():
				enterIdle()
			else:
				setDirection(enemy.global_position.direction_to(pathfinder.get_next_path_position()))
		STATE.APPROACH:
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
			if not pathfinder.is_navigation_finished():
				var nextPosition := pathfinder.get_next_path_position()
				setDirection( enemy.global_position.direction_to(nextPosition) )
		STATE.FIGHT:
			if not vixInFight:
				disengageCounter -= 1
				if disengageCounter <= 0:
					enterApproach()
			determineFightAction()
		STATE.FLEE:
			enemy.flee()

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
				enemy.velocity = enemy.global_position.direction_to(vixReference.global_position)
				enemy.coordinator.movement.determineSpriteFlip()
				if randi() % 100 < attackOnePreference && enemy.coordinator.canAttack("attack0"): 
					requestAction("attack0")
				elif enemy.coordinator.canAttack("attack1"):
					requestAction("attack1")
		FIGHT_STYLE.DEFENSIVE:
			if randi() % 100 > 90:
				setDirection(-(enemy.global_position.direction_to(pathfinder.get_next_path_position())))
			var actionDecision : int = randi() % 100
			if enemy.coordinator.guard.isGuarding() && actionDecision < 30:
				requestAction("unblock")
			if actionDecision < 30:
				enemy.velocity = enemy.global_position.direction_to(vixReference.global_position)
				enemy.coordinator.movement.determineSpriteFlip()
				if randi() % 100 < attackOnePreference && enemy.coordinator.canAttack("attack0"): 
					requestAction("attack0")
				elif enemy.coordinator.canAttack("attack1"):
					requestAction("attack1")
			elif actionDecision < 20:
				requestAction("dodge")
			else:
				if enemy.coordinator.canBlock():
					requestAction("block")
		FIGHT_STYLE.MOBILE:
			if randi() % 100 > 60:
				setDirection(-(enemy.global_position.direction_to(pathfinder.get_next_path_position())))
			var actionDecision : int = randi() % 100
			if enemy.coordinator.guard.isGuarding() && actionDecision < 80:
				requestAction("unblock")
			if actionDecision < 30:
				enemy.velocity = enemy.global_position.direction_to(vixReference.global_position)
				enemy.coordinator.movement.determineSpriteFlip()
				if randi() % 100 < attackOnePreference && enemy.coordinator.canAttack("attack0"): 
					requestAction("attack0")
				elif enemy.coordinator.canAttack("attack1"):
					requestAction("attack1")
			elif actionDecision < 20:
				if enemy.coordinator.canBlock():
					requestAction("block")
			else:
				requestAction("dodge")
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
