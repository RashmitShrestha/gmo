class_name Dummy
extends GameCharacter

var warden:Warden

func _ready():
	warden = %Warden
	var area = $DummyArea
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	area.connect("mouse_entered", _on_mouse_entered)


func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)


func _on_damage_enemy(character:GameCharacter, slice_velocity:float):
	if character == self:
		print(str(self) + " dmg: " + str(slice_velocity ))
