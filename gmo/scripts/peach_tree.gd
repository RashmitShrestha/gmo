extends Area2D

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interact = open_skill_tree

func open_skill_tree() -> void:
	var skill_tree_menu = get_tree().get_first_node_in_group("skill_tree_menu")
	if skill_tree_menu:
		skill_tree_menu.show_menu()
