class_name HurtBox
extends Area2D
## Detects all types of hitboxes
##
## This class calls a receive_hit_payload method its owner must have.
## A HitPayload class is passed through the method mentioned.

@export var hurtBoxOwner: Node;

func _init() -> void:
	monitoring = true;
	monitorable = false;
	set_collision_layer_value(CollisionLayers.ENEMY,false)
	set_collision_mask_value(CollisionLayers.ENEMY,true)
	set_collision_mask_value(CollisionLayers.ENVIROMENT,true)
	
	# Connect Area2D's area_entered signal
	area_entered.connect(_on_area_entered)

func _ready() -> void:
	if !hurtBoxOwner:
		hurtBoxOwner = owner
	
	assert(hurtBoxOwner.has_method("receive_hit_payload"),"No valid owner for hurtbox.")

# Handles collision with HitBox
func _on_area_entered(area: Area2D) -> void:
	if area is not HitBox :
		return
	
	var hitbox: HitBox = area
	
	@warning_ignore("unsafe_method_access") # method call is not unsafe. Check line 20
	hurtBoxOwner.receive_hit_payload(hitbox.get_payload())
