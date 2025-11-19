class_name PlayerAnimationManagerComponent
extends AnimationManagerComponent


func update(character) -> void:
	if (character.velocity == Vector2.ZERO):
		character.animation_tree["parameters/conditions/idle"] = true
		character.animation_tree["parameters/conditions/is_moving"] = false
	else: 
		character.animation_tree["parameters/conditions/idle"] = false
		character.animation_tree["parameters/conditions/is_moving"] = true
		
	if character.damaged:
		character.animation_tree["parameters/conditions/hurt"] = true
		character.damaged = false
	else: 
		character.animation_tree["parameters/conditions/hurt"] = false
	
	if character.direction != Vector2.ZERO:
		character.animation_tree["parameters/Run/blend_position"] = character.direction
