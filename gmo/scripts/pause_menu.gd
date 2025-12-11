extends CanvasLayer

@onready var control: Control = $Control
@onready var tutorial_button: Button = %TutorialButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	if SignalBus.show_pause_menu_on_load:
		SignalBus.show_pause_menu_on_load = false
		show_menu()
	else:
		control.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_menu"):
		var skill_tree = get_tree().get_first_node_in_group("skill_tree_menu")
		if skill_tree and skill_tree.control.visible:
			return

		if control.visible:
			hide_menu()
		else:
			show_menu()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	control.visible = true
	get_tree().paused = true

func hide_menu() -> void:
	control.visible = false
	get_tree().paused = false

func _on_tutorial_pressed() -> void:
	SignalBus.tutorial_return_to_game = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://how_to_play.tscn")

func _on_quit_pressed() -> void:

	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
