class_name VixWeapon extends Node2D
@onready var swing : AnimationPlayer = $swing
@export var user : Entity
@export var cooldown : float = 1.0
var onCooldown : bool = false
func _ready() -> void:
	$cooldown.wait_time = cooldown
	if user is Vix:
		$katana.set_collision_mask_value(2, true)
	else:
		$katana.set_collision_mask_value(1, true)
func use() -> void:
	onCooldown = true
	$swing.play("swing")
	$cooldown.start()
func canUse() -> bool:
	return not onCooldown
func _on_cooldown_timeout() -> void:
	onCooldown = false
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Entity:
		body.takeDamage(max(1, user.getAttack() - body.getDefense()))
