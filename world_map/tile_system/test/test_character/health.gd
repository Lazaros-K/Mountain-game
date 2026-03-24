extends Node2D
class_name Health
#Health changing signals
signal health_changed(new_health: int)
signal died

@export var max_health: int = 100;
@onready var health: int = max_health
@export var invincibility_duration: float = 0.5

var is_invincible: bool = false

func _ready() -> void:
	health_changed.emit(health)

#Induces Damage, clamps health to a set range and checks
#if the player is dead
func damage(amount: int) -> void:
	if is_invincible:
		return 
	
	health = clamp(health - amount, 0, max_health)
	
	health_changed.emit(health)
	print("Damage hit: ",amount," Total Health: ",health)
	
	if health <=0:
		die()
	else:
		start_invincibility()

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

func die() -> void:
	died.emit()
	print("Player Died")
	get_parent().queue_free()
