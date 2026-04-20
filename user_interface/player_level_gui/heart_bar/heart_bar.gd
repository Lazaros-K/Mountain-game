class_name hearts
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
