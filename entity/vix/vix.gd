extends Entity
class_name Vix

@onready var katana : VixWeapon = $vixWeapon

func _ready() -> void:
	health = maxHealth
var lastNonZeroDir = Vector2.RIGHT
func _process(_delta: float) -> void:
	var dir : Vector2 = Input.get_vector("left","right","up","down")
	if dir:
		lastNonZeroDir = dir
	if Input.is_action_just_pressed("attack") and katana.canUse():
		katana.use()
	if not katana.onCooldown:
		katana.rotation = lastNonZeroDir.angle()
	velocity = dir * moveSpeed
	move_and_slide()
