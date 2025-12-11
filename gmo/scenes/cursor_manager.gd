extends Node

# Load the custom images for the mouse cursor.
var default = load("res://assets/Cursor.png")
var sword = load("res://assets/cursor_sword.png")


func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(default)

func set_default():
	Input.set_custom_mouse_cursor(default)

func set_sword():
	Input.set_custom_mouse_cursor(sword)
