extends CanvasLayer

@export var text: Array[String]
@export var images: Array[TextureRect]
@export var typing_speed: float

var curr_scene: int = 0
var curr_text: String = ""
var typing: bool = false

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	_show_cutscene()


func _show_cutscene() -> void:
	texture_rect.texture = images[curr_scene].texture
	curr_text = ""
	typing = true


func _type() -> void:
	for i in text[curr_scene]:
		if not typing:
			break
			
		curr_text += i
		label.text = curr_text
		
		await get_tree().create_timer(typing_speed).timeout
	
	typing = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if typing:
			typing = false
		else:
			_advance()


func _advance() -> void:
	curr_scene += 1
	
	if curr_scene == len(text):
		get_tree().change_scene_to_file("res://scenes/game_area.tscn")
		return
	
	_show_cutscene()
