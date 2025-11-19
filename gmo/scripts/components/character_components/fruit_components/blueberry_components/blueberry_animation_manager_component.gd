class_name BlueberryAnimationManagerComponent
extends AnimationManagerComponent


func update(character: Blueberry) -> void:
	character.animation_tree["parameters/conditions/idle"] = true
	
	if character._damaged:
		character.animation_tree["parameters/conditions/hurt"] = true
		character._damaged = false
	else: 
		character.animation_tree["parameters/conditions/hurt"] = false
