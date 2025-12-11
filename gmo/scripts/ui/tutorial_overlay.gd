extends CanvasLayer

@onready var tutorial_content: Control = null
var tutorial_scene_path: String = "res://how_to_play.tscn"
var pause_menu: CanvasLayer = null

func _ready() -> void:
	visible = false
	pause_menu = get_tree().get_first_node_in_group("pause_menu")


	process_mode = Node.PROCESS_MODE_ALWAYS

	SignalBus.show_tutorial_overlay.connect(_on_show_tutorial)
	SignalBus.hide_tutorial_overlay.connect(_on_hide_tutorial)

	print("TutorialOverlay: Ready and waiting for signal")

func _on_show_tutorial() -> void:
	print("TutorialOverlay: show_tutorial signal received")

	if tutorial_content == null:
		print("TutorialOverlay: Loading tutorial scene...")
		var tutorial_scene = load(tutorial_scene_path)
		if tutorial_scene:
			tutorial_content = tutorial_scene.instantiate()

			tutorial_content.set_script(null)

			tutorial_content.process_mode = Node.PROCESS_MODE_ALWAYS
			_set_process_mode_recursive(tutorial_content, Node.PROCESS_MODE_ALWAYS)

			add_child(tutorial_content)

			var back_button = tutorial_content.get_node_or_null("MarginContainer/VBoxContainer/BackButton")
			if back_button:
				back_button.pressed.connect(_on_tutorial_back)
				print("TutorialOverlay: Back button connected")
			else:
				print("TutorialOverlay: WARNING - Back button not found")
		else:
			print("TutorialOverlay: ERROR - Failed to load tutorial scene")

	if tutorial_content:
		tutorial_content.visible = true

	visible = true

func _set_process_mode_recursive(node: Node, mode: Node.ProcessMode) -> void:
	node.process_mode = mode
	for child in node.get_children():
		_set_process_mode_recursive(child, mode)

func _on_hide_tutorial() -> void:
	visible = false
	if pause_menu:
		pause_menu.control.visible = true
		print("TutorialOverlay: Pause menu shown")
	else:
		print("TutorialOverlay: WARNING - pause_menu is null!")

func _on_tutorial_back() -> void:
	_on_hide_tutorial()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("escape_menu"):
		_on_tutorial_back()
		get_viewport().set_input_as_handled()
