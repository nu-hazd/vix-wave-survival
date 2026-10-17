extends Resource
class_name NightData

enum BOSS {
	BOSS0
}

@export var boss : BOSS = BOSS.BOSS0 
@export var waves : Array[Wave]

func getWaveAmount() -> int:
	return waves.size()
