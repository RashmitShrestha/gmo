class_name Blueberry
extends GameCharacter

var warden:Warden

@export var animation_manager_component: BlueberryAnimationManagerComponent

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	var area = $DummyArea
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	area.connect("mouse_entered", _on_mouse_entered)


func _process(_delta) -> void:
	animation_manager_component.update(self)


func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)


func _on_damage_enemy(character:GameCharacter, slice_velocity:float):
	if character == self:
		damaged = true
		print(str(self) + " dmg: " + str(slice_velocity ))
		
