# skill_tree_lines.gd
extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	var skill_tree = get_parent().get_parent().get_parent()
	
	if not skill_tree.has_method("get_connections"):
		return
	
	var connections = skill_tree.get_connections()
	var skill_nodes = skill_tree.get_skill_nodes()
	
	for connection in connections:
		var from_id = connection[0]
		var to_id = connection[1]
		
		if skill_nodes.has(from_id) and skill_nodes.has(to_id):
			var from_btn = skill_nodes[from_id]
			var to_btn = skill_nodes[to_id]
			
			# Get the container position + button center
			var from_container = from_btn.get_parent()
			var to_container = to_btn.get_parent()
			
			var from_pos = from_container.position + from_btn.position + from_btn.size / 2
			var to_pos = to_container.position + to_btn.position + to_btn.size / 2
			
			draw_line(from_pos, to_pos, Color.WHITE, 3.0)
