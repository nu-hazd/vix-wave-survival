extends Resource
class_name Wave

@export var spawns : Dictionary[StringName, int]

func getEnemyCount() -> int:
	var count : int = 0
	for key : StringName in spawns.keys():
		count+= spawns[key]
	return count
