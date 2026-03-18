extends Node2D

#health changing signals for ui
signal health_changed(new_health: int)
signal died

@export var max_health: int = 100;
@onready var health: int = max_health

func _ready() -> void:
	health_changed.emit(health)

func damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	
	health_changed.emit(health)
	
	if health <=0:
		die()

func die() -> void:
	died.emit()
	get_parent().queue_free()
