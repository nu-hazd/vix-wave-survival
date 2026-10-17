class_name Enemy extends Entity 


signal spared
signal despawnEnemy(enemy : Enemy)
 
@export var despawnTimer : Timer
var spareCounter : int = 0

func _on_health_dead() -> void:
	controller.set_physics_process(false)
	$bars.visible = false
	despawnTimer.start()
func _on_despawn_timer_timeout() -> void:
	despawnEnemy.emit(self)

func spareEnemy() -> void:
	pass
