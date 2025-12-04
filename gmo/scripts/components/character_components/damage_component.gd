class_name DamageComponent
extends Node

@export var hitbox: Area2D
@export var damage_amount: float

const DamageNumber = preload("res://scenes/ui/damage_number.tscn")  # Adjust path as needed

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
		spawn_damage_number(character)

func spawn_damage_number(character: GameCharacter) -> void:
	var damage_number = DamageNumber.instantiate()
	character.get_parent().add_child(damage_number)
	damage_number.global_position = character.global_position + Vector2(0, -30)  # This line is missing!
	damage_number.z_index = 100
	damage_number.set_damage(int(damage_amount))
