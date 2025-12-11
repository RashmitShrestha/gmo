extends Control

@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	if SignalBus.tutorial_return_to_game:
		SignalBus.tutorial_return_to_game = false
		SignalBus.show_pause_menu_on_load = true
		get_tree().change_scene_to_file("res://scenes/game_area.tscn")
	else:
		get_tree().change_scene_to_file("res://main_menu.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("escape_menu"):
		_on_back_pressed()
