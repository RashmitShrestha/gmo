class_name PlayerAnimationManagerComponent
extends AnimationManagerComponent


func update() -> void:
	if (_parent.velocity == Vector2.ZERO):
		_parent.animation_tree["parameters/conditions/idle"] = true
		_parent.animation_tree["parameters/conditions/is_moving"] = false
	else: 
		_parent.animation_tree["parameters/conditions/idle"] = false
		_parent.animation_tree["parameters/conditions/is_moving"] = true
		
	if _parent.damaged:
		_parent.animation_tree["parameters/conditions/hurt"] = true
		_parent.damaged = false
	else: 
		_parent.animation_tree["parameters/conditions/hurt"] = false
	
	if _parent.direction != Vector2.ZERO:
		_parent.animation_tree["parameters/Run/blend_position"] = _parent.direction
