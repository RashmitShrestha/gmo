class_name DamageComponent
extends Node
@export var hitbox: Area2D
@export var damage_amount: float
@export var element_type: int  # 0 = no element, 1 = fire, 2 = frozen, 3 = ferment
var _parent: GameCharacter
var is_curr_dot : bool

func _ready() -> void:
	_parent = get_parent()
	element_type = _parent.element 
	
	if element_type == 0:
		is_curr_dot = false
	else:
		is_curr_dot = true
	
	hitbox.body_entered.connect(
		func(body: Node2D):
			if body is PeachTree:
				# Check if this is a valid target
				if not _is_valid_target(body):
					return
				
				if _parent is Fruit:
					_parent.is_attacking = true
				
				_damage(body)
	)

func _physics_process(_delta: float) -> void:
	for body in hitbox.get_overlapping_bodies():
		if body is Warden:
			# Check if this is a valid target
			if not _is_valid_target(body):
				continue
			
			if _parent is Fruit:
				_parent.is_attacking = true
			
			_damage(body)

func _is_valid_target(target: GameCharacter) -> bool:
	# If parent is a fertilized fruit, it can attack other fruits
	if _parent is Fruit and _parent.fertilized:
		# Can attack other fruits (both fertilized and non-fertilized)
		if target is Fruit and target != _parent:
			return true
		# Cannot attack warden or tree
		return false
	
	# If parent is a normal (non-fertilized) fruit
	if _parent is Fruit and not _parent.fertilized:
		# Normal fruits attack warden and tree, not other fruits
		if target is Fruit:
			return false
		return true
	
	# For non-fruit characters (like warden)
	return true

func _damage(character: GameCharacter) -> void:
	if not character.invulnerable:
		SignalBus.char_damaged_char.emit(_parent, character)
		character.apply_damage(damage_amount, _parent, element_type, false)
