class_name Slice
extends Line2D
var points_queue : Array

var max_trail = 5
var max_points = 100

var current_element = -1
var element_ready = -1

var active_trails : Array = []


var element_colors = {
	1: Color(0.871, 0.235, 0.2, 0.7),
	2: Color(0.275, 0.412, 0.988, 0.7),
	3: Color(0.702, 0.937, 0.306, 0.7)
}

var element_duration = 10.0

func _ready():
	width = 20.0
	set_as_top_level(true)
	
func _process(delta):
	for i in range(active_trails.size() - 1, -1, -1):
		# reduce the active trails timer in process
		active_trails[i].timer -= delta
		
		# if any are zero then queue the free and remove them 
		if active_trails[i].timer <= 0:
			active_trails[i].line.queue_free()
			active_trails.remove_at(i)
			
			
func slicing(mouse_pos: Vector2) -> void:
	if current_element < 0:
		return
	# push the points based on the global to local mouse position 
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
		clear_points()
		points_queue = []
		
		current_element = element

		# create a new gradient and color system based on the predefined element colors
		var grad = Gradient.new()
		var color = element_colors[element]
		# the first stop at 0 is the darker version of the colors 
		grad.add_point(0.0, Color(color.r - 0.3, color.g - 0.3, color.b - 0.3, 0.8))
		grad.add_point(1.0, Color(color.r, color.g, color.b, 0.6))
		
		gradient = grad
		width = 20.0
		
func end_trail() -> void:
	# if the current element is not empty and the points queue is not empty
	if current_element >= 0 and points_queue.size() > 0:
		var trail_line = Line2D.new()
		# important to set line as top level
		trail_line.set_as_top_level(true)
		trail_line.width = 10.0
		
		var grad = Gradient.new()
		var color = element_colors[current_element]
		grad.add_point(0.0, Color(color.r - 0.3, color.g - 0.3, color.b - 0.3, 0.8))
		grad.add_point(1.0, Color(color.r, color.g, color.b, 0.6))
		
		trail_line.gradient = grad
		
		# turn local points to global points because Slice is inside Warden node
		var global_points = []
		for p in points_queue:
			var global_point = to_global(p)
			trail_line.add_point(global_point)
			global_points.append(global_point)
		
		get_parent().add_child(trail_line)
		
		# active trails are based on the line, element, points, and timer
		active_trails.append({
			"line": trail_line,
			"element": current_element,
			"points": global_points,  # Store global points for collision detection
			"timer": element_duration
		})

	current_element = -1
	element_ready = -1
	width = 20
	clear_points()
	points_queue = []
	
# simply sets the ready element to the passed in element int 
func set_element(element: int) -> void:
	element_ready = element
