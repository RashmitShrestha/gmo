extends StaticBody2D

func _ready() -> void:
	SignalBus.tree_died.connect(_on_tree_died)

func _on_tree_died() -> void:
	queue_free()

