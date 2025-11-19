class_name BlueberryAnimationManagerComponent
extends AnimationManagerComponent


func update(character: Blueberry) -> void:
	character.animation_tree["parameters/conditions/idle"] = true
	
	if character.damaged:
		character.animation_tree["parameters/conditions/hurt"] = true
		character.damaged = false
	else: 
		character.animation_tree["parameters/conditions/hurt"] = false
