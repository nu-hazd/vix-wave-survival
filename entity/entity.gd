class_name Entity extends CharacterBody2D


signal dead
@onready var coordinator: Coordinator = $coordinator
@onready var controller: ControllerComponent = $controller

@export var sprite : Sprite2D
@export var stats : EntityStatsComponent

func _ready() -> void:
	controller.actionRequested.connect(coordinator.actionRequested)
	controller.directionChanged.connect(coordinator.directionChanged)
	coordinator.entityDied.connect(died)
	coordinator.start(self)

func died() -> void:
	dead.emit()
