class_name HitPayload
extends Node
## Class containing hit data, useful for the entity recieving the hit

var id: String
var damage: int
var actor: Node2D

func _init(_id: String, _damage: int, _actor: Node2D) -> void:
	id = _id
	damage = _damage
	actor = _actor

func info() -> void:
	print("Hit id: " + id)
	print("Hit damage: %d" % damage)
