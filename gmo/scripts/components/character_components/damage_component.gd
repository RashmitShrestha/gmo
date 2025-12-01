@abstract class_name DamageComponent
extends Node

var _parent

func _ready() -> void:
	_parent = get_parent()

@abstract func update() -> void
