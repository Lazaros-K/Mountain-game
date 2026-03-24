class_name Attack
## Class containing entity attack data, useful for the AttackHitBox

var id: String
var one_time: bool
var damage: int
var attack_duration: float
var attack_shape: Shape2D

func _init(_id: String, _attack_shape: Shape2D, _damage: int, _attack_duration: float, _one_time: bool) -> void:
	id = _id
	damage = _damage
	attack_duration = _attack_duration
	one_time = _one_time
	attack_shape = _attack_shape

func info() -> void:
	print("Attack id: " + id)
	print("Attack damage: %d" % damage)
	if one_time:
		print("One time attack")
