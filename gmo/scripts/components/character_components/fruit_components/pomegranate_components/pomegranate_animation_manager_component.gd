class_name PomegranateAnimationManagerComponent
extends AnimationManagerComponent


func update() -> void:
	_parent.animation_tree["parameters/conditions/idle"] = true
	
	if _parent.damaged:
		_parent.animation_tree["parameters/conditions/hurt"] = true
		_parent.damaged = false
	else: 
		_parent.animation_tree["parameters/conditions/hurt"] = false
