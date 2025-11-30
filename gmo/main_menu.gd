extends Control

func _ready():
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit)

func play():
	get_tree().change_scene_to_file("res://scenes/game_area.tscn")
	
func quit():
	get_tree().quit()
