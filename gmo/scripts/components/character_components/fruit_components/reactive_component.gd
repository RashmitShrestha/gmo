@abstract class_name ReactiveComponent
extends Node

var _parent: Fruit

func _ready() -> void:
	_parent = get_parent()

@abstract func update() -> void
