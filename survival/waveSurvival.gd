extends Node2D
class_name WaveSurvival
enum EXIT_CODE {
	LOSE,
	NIGHT_OVER,
	BOSS_SPARE,
	BOSS_KILL
}

signal exit(result : EXIT_CODE, points : int)

const enemyScenes : Dictionary[StringName, PackedScene] = {
	"katanaOffensive" : preload("res://entity/enemies/footSoldiers/katanaOffensive.tscn"),
	"greatswordDefensive" : preload("res://entity/enemies/footSoldiers/greatswordDefensive.tscn"),
	"daggerMobile" : preload("res://entity/enemies/footSoldiers/daggerMobile.tscn")
} 
const nightMinutes : int = 4
const nightDuration : int = 60 * 60 * nightMinutes
var currentTime : int =0
var displayedHour: int = -1
var nightNum : int = 0
@onready var spawn_pos: Marker2D = $spawnPos
@onready var enemyNode : Node2D = $enemies
@onready var info : WaveInfoUI = $nightTimer/info
var vix : Vix


var nightPoints : int = 0
var instinctMultiplier : int = 0

var waveEnemyDefeated : int 
var waves : Array[Wave]
var currentWave : int = -1

var spawnPoints : Array[Marker2D]
func _ready() -> void:
	set_physics_process(false)
	for child in $spawnpoints.get_children():
		if child is Marker2D:
			spawnPoints.push_back(child)

func _physics_process(_delta: float) -> void:
	currentTime += 1
	var newHour := mini(
		floori(float(currentTime) / nightDuration * 6.0),
		6
	)
	if newHour == 6:
		endNight(EXIT_CODE.NIGHT_OVER)
	elif isBossKilled():
		endNight(EXIT_CODE.BOSS_KILL)
	elif isWaveOver():
		spawnWaveNextWave()
	if newHour != displayedHour:
		displayedHour = newHour
		info.updateClock(nightNum, currentTime, nightDuration)
	if vix:
		if vix.ded:
			endNight(EXIT_CODE.LOSE)

func startNight(num : int, nightData : NightData):
	$music.play()
	add_child(vix)
	vix.enableCombat()
	vix.camera.enabled = true
	vix.position = spawn_pos.position
	displayedHour = -1
	currentTime = 0
	currentWave = -1
	waves = nightData.waves
	$nightTimer.visible = true
	nightNum = num
	info.updateClock(nightNum,currentTime,nightDuration)
	spawnWaveNextWave()
	set_physics_process(true)
func isWaveOver() -> bool:
	if currentWave >= waves.size():
		return isBossKilled()
	return waves[currentWave].getEnemyCount() <= waveEnemyDefeated
func isBossKilled() -> bool:
	return false
func despawnEnemy(enemy : Enemy) -> void:
	waveEnemyDefeated += 1
	enemyNode.remove_child(enemy)
	enemy.queue_free()
func spawnWaveNextWave() -> void:
	currentWave += 1
	info.updateWave(currentWave,waves.size())
	if currentWave >= waves.size():
		endNight(EXIT_CODE.NIGHT_OVER)
	else:
		waveEnemyDefeated = 0
		var spwns : Dictionary[StringName,int] = waves[currentWave].spawns
		for key : StringName in spwns.keys():
			if enemyScenes.has(key):
				var availableSpawns : Array[int] = [0,1,2,3,4,5,6,7,8]
				for i in range(spwns[key]):
					var selectRandom : int = availableSpawns.pick_random()
					availableSpawns.erase(selectRandom)
					var randSpawn : Marker2D = spawnPoints[selectRandom]
					var enemy : Enemy = enemyScenes[key].instantiate()
					enemyNode.add_child(enemy)
					enemy.controller.vixReference = vix
					enemy.global_position = randSpawn.global_position
					enemy.despawnEnemy.connect(despawnEnemy)
			else:
				push_warning("Invalid spawn ID: %s" % key)
		
func spawnBoss() -> void:
	pass
func endNight(code : EXIT_CODE) -> void:
	$music.stop()
	$nightTimer.visible = false
	for ene in $enemies.get_children():
		ene.queue_free()
	exit.emit(code, nightPoints)
