extends Node2D


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		var c = get_child(get_child_count() - 1)
		
		if c is Node2D and not c.is_in_group("background"):
			$YSort.add_child(c)
