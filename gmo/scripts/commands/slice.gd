extends Line2D

var points_queue : Array
var max_points = 5 # limited trail
# in Slice's inspector area 

func slicing() -> void:
	var pos = get_global_mouse_position()
	
	points_queue.push_front(pos)
	
	if points_queue.size() > max_points:
		points_queue.pop_back()
		
	clear_points()
	
	for p in points_queue:
		add_point(p)
