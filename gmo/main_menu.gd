extends Control

func _ready():
	%Play.pressed.connect(play)
	%HowToPlay.pressed.connect(how_to_play)
	%Quit.pressed.connect(quit)

func play():
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")

func how_to_play():
	SignalBus.tutorial_return_to_game = false
	get_tree().change_scene_to_file("res://how_to_play.tscn")
	
func quit():
	get_tree().quit()
