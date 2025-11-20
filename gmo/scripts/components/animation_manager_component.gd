@abstract class_name AnimationManagerComponent
extends Node

var _parent

func _ready() -> void:
	_parent = get_parent()

@abstract func update() -> void
