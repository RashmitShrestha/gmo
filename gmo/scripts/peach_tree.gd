class_name PeachTree
extends GameCharacter

@onready var interactable: Interactable = $Interactable

var is_dead: bool = false

func _ready() -> void:
	add_to_group("peach_tree")
	interactable.interact = open_skill_tree
	received_damage.connect(
		func(_damage: float, _source: Node2D):
			SignalBus.base_health_changed.emit(curr_health, max_health)

			if curr_health <= 0.0 and not is_dead:
				_die()
	)

	SignalBus.base_health_changed.emit(curr_health, max_health)

func _die() -> void:
	is_dead = true
	print("peachTree has been destroyed!")

	SignalBus.tree_died.emit()
	if interactable:
		interactable.interact = func(): pass
		interactable.monitoring = false
		interactable.monitorable = false


	modulate = Color(0.5, 0.5, 0.5, 0.7)

func open_skill_tree() -> void:
	var skill_tree_menu = get_tree().get_first_node_in_group("skill_tree_menu")
	if skill_tree_menu:
		skill_tree_menu.show_menu()
