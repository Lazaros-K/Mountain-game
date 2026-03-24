class_name StaticHitBox
extends HitBox
## A static hitbox

@export var hazard_name: String
@export var damage: int

func _init() -> void:
	pass

func get_payload() -> HitPayload :
	return HitPayload.new(hazard_name, damage, self)
