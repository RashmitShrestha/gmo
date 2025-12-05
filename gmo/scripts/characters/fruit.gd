class_name Fruit 
extends GameCharacter

# only enemies can have a element type

# 0 = none
# 1 = flame
# 2 = frozen
# 3 = ferment
var element : int
var stun_time: float = 1.0


var warden: Warden
var stunned: bool = false

var dead: bool = false
var is_attacking: bool = false

# indicates whether its affeted by the fertilized ability
var fertilized : bool = false

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	animation_player.animation_finished.connect(_on_death)
	if warden == null:
		warden = get_node_or_null("%Warden")
		if warden == null:
			warden = get_parent().get_node_or_null("Warden") if get_parent() else null

	#SignalBus.damage_enemy.connect(_on_damage_enemy)
	SignalBus.skill_damage_enemy.connect(_on_skill_damage_enemy)


func _on_damage_enemy(character: GameCharacter, slice_velocity: float):
	if character == self:
		var damage = SliceDamage.calculate_damage(slice_velocity, 1.0)
		curr_health -= damage
		
		print(str(self) + " took " + str(damage) + " damage. Health: " + str(curr_health))
		
		if curr_health <= 0:
			animation_tree.active = false
			animation_player.play("death")
			dead = true


func _on_skill_damage_enemy(character: GameCharacter, dmg: float, element_type: int):
	if character == self:
		curr_health -= dmg
		
		if curr_health <= 0:
			animation_tree.active = false
			animation_player.play("death")
			dead = true

		print(str(self) + " took " + str(dmg) + " damage from element " + str(element_type) + ". Health: " + str(curr_health))


func apply_damage(damage: float, _source: Node2D):
	super(damage, _source)

	if curr_health <= 0.0:
		animation_tree.active = false
		animation_player.play("death")
		dead = true


func _on_death(animation_name: StringName):
	if animation_name == "death":
		_die()
