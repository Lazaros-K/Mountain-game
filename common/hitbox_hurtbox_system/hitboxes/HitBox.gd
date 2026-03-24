@abstract
class_name HitBox
extends Area2D
## Basic HitBox abstract class

func _init() -> void:
	monitoring = false;
	monitorable = true;

@abstract
func get_payload() -> HitPayload
