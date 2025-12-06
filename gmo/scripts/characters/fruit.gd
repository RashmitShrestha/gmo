class_name Fruit 
extends GameCharacter

var element : int  # This Fruit's element type
var stun_time: float = 1.0
var warden: Warden
var peach_tree: PeachTree
var target: GameCharacter
var stunned: bool = false
var dead: bool = false
var is_attacking: bool = false
var fertilized : bool = false

@onready var animation_tree: AnimationTree = $AnimationTree

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	if dead:
		return
		
	_face_warden()

func _ready():
	add_to_group("enemies")
	super._ready()  # Call parent _ready
	
	SignalBus.player_died.connect(func(): target = peach_tree)
	
	animation_tree.active = true
	animation_player.animation_finished.connect(_on_death)
	
	if warden == null:
		warden = get_node_or_null("%Warden")
		if warden == null:
			warden = get_parent().get_node_or_null("Warden") if get_parent() else null
	if peach_tree == null:
		peach_tree = get_node_or_null("%PeachTree")
		if peach_tree == null:
			peach_tree = get_parent().get_node_or_null("PeachTree") if get_parent() else null
	
	target = warden
	
	# Only need damage_enemy signal - it handles everything
	SignalBus.damage_enemy.connect(_on_damage_enemy)


func _on_damage_enemy(character: GameCharacter, damage: float, element_type: int = 0):
	if character == self:
		apply_damage(damage, self, element_type)


func apply_damage(damage: float, _source: Node2D, elem: int = 0):
	super(damage, _source, elem)
	
	if curr_health <= 0.0:
		animation_tree.active = false
		animation_player.play("death")
		dead = true


func _on_death(animation_name: StringName):
	if animation_name == "death":
		_die()


func _face_warden() -> void:
	var direction_to_warden: float = target.global_position.x - global_position.x
	
	# turn around if warden is behind fruit
	if direction_to_warden < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
