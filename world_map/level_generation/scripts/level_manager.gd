extends Node

@export var right_rooms: Array[PackedScene]
@export var up_rooms: Array[PackedScene]

@onready var rooms_container = self

var next_spawn_position = Vector2.ZERO

func _ready():
	for i in range(10):
		spawn_random_room()

#Picks a room randomly and spawns it in a set poosition depending on the markers
func spawn_random_room()-> void:
	var room_to_spawn: PackedScene
	
	if randf() > 0.75:
		room_to_spawn = right_rooms.pick_random()
	else:
		room_to_spawn = up_rooms.pick_random()
		
	var new_room = room_to_spawn.instantiate()
	rooms_container.add_child(new_room)
	
	var entrance_marker = new_room.get_node_or_null("EntrancePoint")
	
	if entrance_marker != null:
		var offset = entrance_marker.position
		new_room.global_position = next_spawn_position - offset
	else:
		new_room.global_position = next_spawn_position
	
	var exit_marker = new_room.get_node("ExitPoint")
	
	if exit_marker != null:
		next_spawn_position = exit_marker.global_position
