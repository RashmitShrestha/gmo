class_name Slice
extends Line2D

var points_queue : Array
var max_trail = 5
var max_points = 100
var current_element = -1
var element_ready = -1
var active_trails : Array = []
var default_state = {}

var element_colors = {
	1: Color(0.871, 0.235, 0.2, 0.7),   # Fire - Red
	2: Color(0.275, 0.412, 0.988, 0.7), # Frozen - Blue
	3: Color(0.702, 0.937, 0.306, 0.7)  # Ferment - Green
}

# How long the trail itself should last
var element_duration = 10.0
var trail_check_interval = 0.1
var trail_check_timer = 0.0

# Effect configurations
var effect_duration = 5.0  # How long effects last after stepping on trail


var element_effects = {
	1: {  # Fire - Pure damage over time
		"dps": 8.0,
		"description": "Burn"
	},
	2: {  # Frozen - Less damage but slows
		"dps": 4.0,
		"slow_multiplier": 0.5,
		"description": "Frozen"
	},
	3: {  # Ferment - Lifesteal
		"dps": 5.0,
		"lifesteal_percent": 0.5,
		"description": "Ferment"
	}
}

func _ready():
	width = 20.0
	set_as_top_level(true)
	capture_default_state()

func capture_default_state() -> void:
	default_state = {
		"width": width,
		"gradient": gradient.duplicate() if gradient else null,
		"default_color": default_color,
		"width_curve": width_curve.duplicate() if width_curve else null,
	}

func restore_default_state() -> void:
	width = default_state.width
	gradient = default_state.gradient.duplicate() if default_state.gradient else null
	default_color = default_state.default_color
	
func _process(delta):
	for i in range(active_trails.size() - 1, -1, -1):
		active_trails[i].timer -= delta
		
		if active_trails[i].timer <= 0:
			active_trails[i].line.queue_free()
			active_trails.remove_at(i)
	
	trail_check_timer += delta
	if trail_check_timer >= trail_check_interval:
		trail_check_timer = 0.0
		check_all_trail_collisions()

func check_all_trail_collisions() -> void:
	if active_trails.is_empty():
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		
		for trail in active_trails:
			if check_enemy_trail_collision(enemy, trail):
				apply_trail_effect(enemy, trail.element)

func check_enemy_trail_collision(enemy: GameCharacter, trail: Dictionary) -> bool:
	var enemy_pos = enemy.global_position
	var collision_radius = 30.0
	
	for i in range(trail.points.size() - 1):
		var segment_start = trail.points[i]
		var segment_end = trail.points[i + 1]
		
		var distance = point_to_segment_distance(enemy_pos, segment_start, segment_end)
		
		if distance <= collision_radius:
			return true
	
	return false

func apply_trail_effect(enemy: GameCharacter, element_type: int) -> void:
	if not element_type in element_effects:
		return
	
	var effect = element_effects[element_type]
	
	var warden = null
	if element_type == 3:
		warden = get_node_or_null("%Warden")
		if not warden:
			warden = get_tree().get_first_node_in_group("player")
		if not warden:
			warden = get_parent().get_node_or_null("Warden")
	
	enemy.apply_dot(element_type, effect.dps, effect_duration, warden)

func point_to_segment_distance(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> float:
	var segment_vec = segment_end - segment_start
	var point_vec = point - segment_start
	
	var segment_length_sq = segment_vec.length_squared()
	
	if segment_length_sq == 0:
		return point.distance_to(segment_start)
	
	var t = clamp(point_vec.dot(segment_vec) / segment_length_sq, 0.0, 1.0)
	var closest_point = segment_start + t * segment_vec
	
	return point.distance_to(closest_point)

func slicing(mouse_pos: Vector2) -> void:
	points_queue.push_front(to_local(mouse_pos))
	
	var max_size = 0
	if current_element >= 0:
		max_size = max_points
	else:
		max_size = max_trail
	
	if points_queue.size() > max_size:
		points_queue.pop_back()
	
	clear_points()
	for p in points_queue:
		add_point(p)
		
func start_trail(element: int) -> void:
	if element in element_colors:
		points_queue = []
		clear_points()
		
		current_element = element
		var grad = Gradient.new()
		var color = element_colors[element]
		grad.add_point(0.0, Color(color.r - 0.3, color.g - 0.3, color.b - 0.3, 0.8))
		grad.add_point(1.0, Color(color.r, color.g, color.b, 0.6))
		
		gradient = grad
		width = 20.0
		
func end_trail() -> void:
	if current_element >= 0 and points_queue.size() > 0:
		var trail_line = Line2D.new()
		trail_line.set_as_top_level(true)
		trail_line.width = 10.0
		
		var grad = Gradient.new()
		var color = element_colors[current_element]
		grad.add_point(0.0, Color(color.r - 0.3, color.g - 0.3, color.b - 0.3, 0.8))
		grad.add_point(1.0, Color(color.r, color.g, color.b, 0.6))
		
		trail_line.gradient = grad
		
		var global_points = []
		for p in points_queue:
			var global_point = to_global(p)
			trail_line.add_point(global_point)
			global_points.append(global_point)
		
		get_parent().add_child(trail_line)
		
		active_trails.append({
			"line": trail_line,
			"element": current_element,
			"points": global_points,
			"timer": element_duration
		})
	
	current_element = -1
	element_ready = -1
	
	restore_default_state()
	clear_points()
	points_queue = []

func set_element(element: int) -> void:
	element_ready = element
