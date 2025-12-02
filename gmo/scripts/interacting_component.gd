extends Node2D
class_name InteractingComponent

@onready var interact_range: Area2D = $InteractRange
@onready var interact_label: Label = $InteractLabel

var current_interactions: Array = []
var can_interact: bool = true


func _ready() -> void:
	interact_label.hide()
	interact_range.area_entered.connect(_on_area_entered)
	interact_range.area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area is Interactable:
		current_interactions.push_back(area)


func _on_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			await current_interactions[0].interact.call()
			can_interact = true


func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		# Sort by nearest
		current_interactions.sort_custom(sort_by_nearest)
		
		# Check if closest interactable can be interacted with
		if current_interactions[0].is_interactable:
			interact_label.text = "F to " + current_interactions[0].interact_name
			interact_label.show()
		else:
			interact_label.hide()
	else:
		interact_label.hide()


func sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area1_distance: float = global_position.distance_to(area1.global_position)
	var area2_distance: float = global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance
