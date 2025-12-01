class_name Strawberry
extends GameCharacter

@export var min_dist: float = 20.0
@export var max_dist: float = 50.0
@export var animation_manager_component: StrawberryAnimationManagerComponent
@export var command_manager_component: StrawberryCommandManagerComponent
@export var reactive_component: StrawberryReactiveComponent

var warden: Warden
var stunned: bool = false
var curr_command: Command
var move_in_command: StrawberryMoveInCommand
var move_out_command: StrawberryMoveOutCommand
var shoot_command: StrawberryShootCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	max_health = 700.0  # 2 full slashes
	curr_health = max_health
	
	animation_tree.active = true
	warden = %Warden
	
	move_in_command = StrawberryMoveInCommand.new(speed)
	move_out_command = StrawberryMoveOutCommand.new(speed)
	shoot_command = StrawberryShootCommand.new()
	
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	$Area2D.connect("mouse_entered", _on_mouse_entered)

func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()

func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)

func _on_damage_enemy(character: GameCharacter, slice_velocity: float):
	if character == self:
		var damage = SliceDamage.calculate_damage(slice_velocity)
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
