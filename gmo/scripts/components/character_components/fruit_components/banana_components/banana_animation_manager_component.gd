class_name BananaAnimationManagerComponent
extends AnimationManagerComponent


func update() -> void:
	_parent.animation_tree["parameters/conditions/idle"] = true
	
	if _parent.damaged:
		_parent.animation_tree["parameters/conditions/hurt"] = true
		_parent.damaged = false
	else: 
		_parent.animation_tree["parameters/conditions/hurt"] = false
	
	if _parent.is_attacking:
		_parent.animation_tree["parameters/conditions/is_attacking"] = true
	else:
		_parent.animation_tree["parameters/conditions/is_attacking"] = false
