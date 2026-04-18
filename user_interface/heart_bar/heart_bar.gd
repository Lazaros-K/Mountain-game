extends CanvasLayer

var hearts_list : Array[TextureRect]
var hits_taken: int = 3; # We start in reverse only because we want the hearts to be removed from right to left.
@onready var h_box_container: HBoxContainer = $Control/HBoxContainer


func _ready() -> void:
	show()
	
	# We add our Hearts (node TextureRect) to an array.
	for child: TextureRect in h_box_container.get_children():
		hearts_list.append(child)
	print(hearts_list)

func receive_damage() -> void:
	if hits_taken > 0:    # Important not to go off array size.
		hits_taken -= 1             
		hearts_list[hits_taken].modulate.a = 0.0 # Make transparent
	else:
		pass

func heal() -> void:
	if hits_taken < 3:  # Important not to go off array size.
		hearts_list[hits_taken].modulate.a = 1.0 # Make opague.
		hits_taken += 1
	else:
		pass

# Goes to "game over" screen when character dies. Press "K" to test.
func die() -> void:
	global_score.score = global_score.score
	get_tree().change_scene_to_file("res://user_interface/end_screen/end_screen.tscn")
	
# Simple heart bar. Press "T" to take damage, "H" to heal.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		receive_damage()
	if event.is_action_pressed("test2"):
		heal()
	if event.is_action_pressed("test3"):
		die()
