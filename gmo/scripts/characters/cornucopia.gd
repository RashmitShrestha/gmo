class_name Cornucopia
extends Fruit

@export var animation_manager_component: CornucopiaAnimationManagerComponent
@export var command_manager_component: CornucopiaCommandManagerComponent
@export var reactive_component: CornucopiaReactiveComponent
@export var knockback_curve: Curve
@export var wait_time: float

var full_slash = 20
var curr_command: Command
var rush_command: CornucopiaRushCommand
var retreat_command: CornucopiaRetreatCommand
var spawn_command: CornucopiaSpawnCommand
var wait_command: CornucopiaWaitCommand

func _ready():
	super()
	
	rush_command = CornucopiaRushCommand.new(speed, self)
	retreat_command = CornucopiaRetreatCommand.new(speed)
	spawn_command = CornucopiaSpawnCommand.new()
	wait_command = CornucopiaWaitCommand.new(wait_time)


func _physics_process(_delta) -> void:
	super(_delta)
	reactive_component.update()

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


'''
func _die():
	print(str(self) + " has been defeated!")
	
	# Hide the grape
	visible = false
	
	# Disable collisions so it doesn't interact anymore
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	# Optional: Play death animation/particles before removing
	# await get_tree().create_timer(0.5).timeout
	
	# Remove from scene tree
	queue_free()

'''
