class_name AttackHitBox
extends HitBox
## Spawnable HitBox meant to be used as an entity attack hitbox
##
## Requires an Attack object in order to be initialised

var attack_value :Attack

func _init(_attack_value :Attack) -> void:
	attack_value = _attack_value
	
	if attack_value.attack_duration > 0 :
		var new_timer: Timer = Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", attack_value.attack_duration)
	
	if attack_value.attack_shape == null:
		push_error("Can not create hitbox with null shape")
		return
	
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.shape = attack_value.attack_shape
	add_child(collision_shape)
	

func get_payload() -> HitPayload :
	return HitPayload.new(attack_value.id, attack_value.damage, self)
