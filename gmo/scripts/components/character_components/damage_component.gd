class_name DamageComponent
extends Node

@export var hitbox: Area2D
@export var damage_amount: float
@export var element_type: int = 0  # 0 = no element, 1 = fire, 2 = frozen, 3 = ferment

var _parent
var is_curr_dot : bool

func _ready() -> void:
	_parent = get_parent()
	
	if element_type == 0:
		is_curr_dot = false
	else:
		is_curr_dot = true
		


func _physics_process(_delta: float) -> void:
	for body in hitbox.get_overlapping_bodies():
		if body is GameCharacter:
			if _parent is Fruit:
				_parent.is_attacking = true
			
			_damage(body)
	if _parent is Fruit:
		_parent.is_attacking = false


func _damage(character: GameCharacter) -> void:
	if not character.invulnerable:
		SignalBus.char_damaged_char.emit(_parent, character)
		print("DAMAGE IS" + str(damage_amount))
		character.apply_damage(damage_amount, _parent, element_type, false)
