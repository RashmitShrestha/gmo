class_name Pomegranate
extends GameCharacter

var _damaged:bool = false
var warden:Warden

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	var area = $DummyArea
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	area.connect("mouse_entered", _on_mouse_entered)


func _process(_delta) -> void:
	update_animation_parameters()


func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)


func _on_damage_enemy(character:GameCharacter, slice_velocity:float):
	if character == self:
		_damaged = true
		print(str(self) + " dmg: " + str(slice_velocity ))
		

func update_animation_parameters():
	animation_tree["parameters/conditions/idle"] = true
	
	if _damaged:
		animation_tree["parameters/conditions/hurt"] = true
		_damaged = false
	else: 
		animation_tree["parameters/conditions/hurt"] = false
		
		
