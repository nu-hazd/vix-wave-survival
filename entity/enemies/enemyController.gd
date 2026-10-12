class_name EnemyController extends ControllerComponent 

@export var enemy : Enemy
@onready var pathfinder: NavigationAgent2D = $"../pathfinder"
var vixReference : Vix

enum FIGHT_STYLE { DEFENSIVE, OFFENSIVE, MOBILE }
enum STATE { WANDER, APPROACH, FLEE, FIGHT}

@export_range(0 ,20, 1, "prefer_slider") var findPlayerChance : int = 5
@export_range(0, 20, 1,"prefer_slider") var fightSkill : int = 5
@export var fightStyle : FIGHT_STYLE = FIGHT_STYLE.DEFENSIVE

var currentState : STATE = STATE.WANDER


var frameCount : int = 0
func _physics_process(_delta: float) -> void:
	frameCount += 1
	if frameCount == 1:
		pass
	match currentState:
		STATE.WANDER:
			pass
			
func getNextWanderPos() -> void:
	pathfinder.target_position = Vector2.INF
	while not pathfinder.is_target_reachable():
		var desired : Vector2 = Vector2(enemy.global_position.x + randi_range(-64,64), enemy.global_position.y + randi_range(-64,64) )
		pathfinder.target_position = desired
	
