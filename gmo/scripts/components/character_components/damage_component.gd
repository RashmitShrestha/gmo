class_name DamageComponent
extends Node

@export var hitbox: Area2D
@export var damage_amount: float

var _parent

func _ready() -> void:
	_parent = get_parent()


func _physics_process(_delta: float) -> void:
	if len(hitbox.get_overlapping_bodies()) != 0:
		if hitbox.get_overlapping_bodies()[0] is GameCharacter:
			if _parent is Fruit:
				_parent.is_attacking = true
			_damage(hitbox.get_overlapping_bodies()[0])
		else:
			if _parent is Fruit:
				_parent.is_attacking = false


func _damage(character: GameCharacter) -> void:
	if not character.invulnerable:
		character.apply_damage(damage_amount, _parent)
