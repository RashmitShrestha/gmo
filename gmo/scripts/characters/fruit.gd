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

# indicates whether its affeted by the fertilized ability
var fertilized : bool = false

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	$Area2D.connect("mouse_entered", _on_mouse_entered)


func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)


func _on_damage_enemy(character: GameCharacter, slice_velocity: float):
	if character == self:
		var damage = SliceDamage.calculate_damage(slice_velocity, 1.0)
		curr_health -= damage
		
		print(str(self) + " took " + str(damage) + " damage. Health: " + str(curr_health))
		
		if curr_health <= 0:
			_die()

func _die():
	print(str(self) + " has been defeated!")
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	queue_free()
