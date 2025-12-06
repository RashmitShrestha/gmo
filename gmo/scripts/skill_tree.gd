extends CanvasLayer

@onready var control: Control = $Control
@onready var lines: Control = $Control/SkillTree/Lines
@onready var nodes: Control = $Control/SkillTree/Nodes
@onready var title_label: Label = $Control/TitleLabel
@onready var path_buttons: HBoxContainer = $Control/PathButtons
@onready var description_box: PanelContainer = $Control/DescriptionBox
@onready var description_label: Label = $Control/DescriptionBox/DescriptionLabel
@onready var flame_btn: Button = $Control/PathButtons/Flame
@onready var frost_btn: Button = $Control/PathButtons/Frost
@onready var ferment_btn: Button = $Control/PathButtons/Ferment


# XP Label to show current XP (add this node to your scene or create it dynamically)
var xp_label: Label

# Dictionary to store node references
var skill_nodes: Dictionary = {}

# Current active path
var current_path: String = "flame"

# Player's current XP (you'll want to connect this to your actual player stats)
var player_xp: int = 100000  # Starting XP for testing

# Track unlocked skills (saved per path)
var unlocked_skills: Dictionary = {
	"flame": [],  # Starting skills (roots) are unlocked by default
	"frost": [],
	"ferment": []
}

# Define skill trees for each path (now with xp_cost!)
var paths: Dictionary = {
	"flame": {
		"title": "Flame Path",
		"nodes": [
			{"id": "+10% Attack", "name": "Grilled Gumption", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your attack damage by 10%."},
			{"id": "1_trail", "name": "Torched and Tender", "pos": Vector2(200, 200), "xp_cost": 100, "description": "For 3 seconds, your main attack leaves a fiery trail that burns enemies. (burn lasts 2 seconds)"},
			{"id": "1_trail_upgrade", "name": "Broiled Brutality", "pos": Vector2(500, 125), "xp_cost": 150, "description": " 'Torched and Tender' is increased to 5 seconds and has double burn damage"},
			{"id": "1_status1", "name": "Carmelized Cruelty", "pos": Vector2(700, 150), "xp_cost": 200, "description": "Crit chance and Crit damage increased by 20% if enemy is burned"},
			{"id": "1_ability", "name": "Flaming Finger", "pos": Vector2(375, 250), "xp_cost": 250, "description": "Flambé enemies with your blowtorch!"},
			{"id": "1_ability_upgrade", "name": "Flambéed Fury", "pos": Vector2(350, 475), "xp_cost": 300, "description": "Your blowtorch range and damage are increased and flambé in all 4 directions."},
			{"id": "1_status2", "name": "Searing Indignation", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Every consecutive attack on an enemy increases CRIT DMG and CRIT chance by 5% until it reaches 100% (Slash window resets after 0.5 seconds)"}
		],
		"connections": [
			["1_trail", "+10% Attack"],
			["1_trail", "1_trail_upgrade"],
			["1_trail", "1_ability"],
			["1_trail_upgrade", "1_status1"],
			["1_ability", "1_ability_upgrade"],
			["1_ability", "1_status2"]
		]
	},
	"frost": {
		"title": "Frost Path",
		"nodes": [
			{"id": "+10% Movement Speed", "name": "Glacial Glide", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your movement speed by 10%."},
			{"id": "2_trail", "name": "Crystallized Cascade ", "pos": Vector2(200, 200), "xp_cost": 100, "description": "Your main attack leaves a trail of ice that slows enemy movement by 50% for 3 seconds"},
			{"id": "2_trail_upgrade", "name": "Permafrost Promenade", "pos": Vector2(500, 125), "xp_cost": 150, "description": "Your frost trail now slows down enemy movement by 75% and its duration is increased to 5 seconds."},
			{"id": "2_status1", "name": "Frostbite Fracture", "pos": Vector2(700, 150), "xp_cost": 200, "description": "20% chance to freeze enemy on hit"},
			{"id": "2_ability", "name": "Freeze Frame", "pos": Vector2(375, 250), "xp_cost": 250, "description": "Freeze all enemies on screen for 4 seconds. (Projectiles can still move)"},
			{"id": "2_ability_upgrade", "name": "Nitrogen Nirvana", "pos": Vector2(350, 475), "xp_cost": 300, "description": "After you activate Freeze Frame, double movement speed, and gain unlimited range. (Freeze Frame duration increased to 7 seconds)"},
			{"id": "2_status2", "name": "Refrigerated Reflexes", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Permanently decrease enemy movement speed by 40%"}
		],
		"connections": [
			["2_trail", "+10% Movement Speed"],
			["2_trail", "2_trail_upgrade"],
			["2_trail", "2_ability"],
			["2_trail_upgrade", "2_status1"],
			["2_ability", "2_ability_upgrade"],
			["2_ability", "2_status2"]
		]
	},
	"ferment": {
		"title": "Fermented Path",
		"nodes": [
			{"id": "+10% Health", "name": "Guano Guard", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your maximum health by 10%."},
			{"id": "3_trail", "name": "Leeching Loam", "pos": Vector2(200, 200), "xp_cost": 100, "description": "For 3 seconds, your main attack leaves a trail of fertilizer that lifesteals from fruits."},
			{"id": "3_trail_upgrade", "name": "Vitamin Vamparism", "pos": Vector2(500, 125), "xp_cost": 150, "description": "Increase fermented trail duration to 5 seconds and siphon 10% ATK from each fruit that touches your fermented trail (Only applies once per trail activation)"},
			{"id": "3_status1", "name": "Regenerative Realization", "pos": Vector2(700, 150), "xp_cost": 200, "description": "Regenerate 2 health every 10 seconds"},
			{"id": "3_ability", "name": "Fertilized Farm", "pos": Vector2(375, 250), "xp_cost": 250, "description": "For 5 seconds every fruit you kill revives as an ally fruit at full health. Ally fruits attack enemy fruit for 10 seconds before fully decaying."},
			{"id": "3_ability_upgrade", "name": "Vineyard Vengeance", "pos": Vector2(350, 475), "xp_cost": 300, "description": "All ally fruits have their base stats doubled."},
			{"id": "3_status2", "name": "Hard to Peel", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Gain a recharging shield that nullifies the first hit from an enemy.(Shield Recharges every 10 seconds)"}
		],
		"connections": [
			["3_trail", "+10% Health"],
			["3_trail", "3_trail_upgrade"],
			["3_trail", "3_ability"],
			["3_trail_upgrade", "3_status1"],
			["3_ability", "3_ability_upgrade"],
			["3_ability", "3_status2"]
		]
	}
}

# Store skill data for quick lookup
var skill_data: Dictionary = {}

# Style resources for different button states
var style_locked: StyleBoxFlat
var style_unlocked: StyleBoxFlat
var style_purchasable: StyleBoxFlat


func _ready() -> void:
	add_to_group("skill_tree_menu")
	control.visible = false
	description_box.visible = false

	# Move title to the right
	title_label.position.x = 450
	
	# Create styles for buttons
	_create_button_styles()
	
	# Create XP label
	_create_xp_label()
	
	print("\n=== RUNTIME PATHBUTTONS CHILDREN ===")
	if has_node("Control/PathButtons"):
		for c in $Control/PathButtons.get_children():
			print(" - ", c.name, " (", c.get_class(), ")")
	else:
		print("PathButtons NOT FOUND at runtime.")
	print("====================================")

	print("Scene loaded from file: ", get_tree().current_scene.scene_file_path)
	print("This script is part of file: ", get_script().resource_path)

	
	_connect_path_buttons()
	
	_load_path(current_path)


func _create_button_styles() -> void:
	# Locked style (dark, greyed out)
	style_locked = StyleBoxFlat.new()
	style_locked.bg_color = Color(0.2, 0.2, 0.2, 0.9)  # Dark grey
	style_locked.border_color = Color(0.3, 0.3, 0.3)
	style_locked.set_border_width_all(2)
	style_locked.set_corner_radius_all(8)
	
	# Unlocked style (green tint)
	style_unlocked = StyleBoxFlat.new()
	style_unlocked.bg_color = Color(0.1, 0.4, 0.1, 0.9)  # Dark green
	style_unlocked.border_color = Color(0.2, 0.8, 0.2)  # Bright green border
	style_unlocked.set_border_width_all(3)
	style_unlocked.set_corner_radius_all(8)
	
	# Purchasable style (can afford, connected to unlocked)
	style_purchasable = StyleBoxFlat.new()
	style_purchasable.bg_color = Color(0.3, 0.3, 0.5, 0.9)  # Blue-ish
	style_purchasable.border_color = Color(0.4, 0.6, 1.0)  # Light blue border
	style_purchasable.set_border_width_all(2)
	style_purchasable.set_corner_radius_all(8)


func _create_xp_label() -> void:
	xp_label = Label.new()
	xp_label.text = "XP: " + str(player_xp)
	xp_label.position = Vector2(900, 20)  # Top right area
	xp_label.add_theme_font_size_override("font_size", 24)
	control.add_child(xp_label)


func _connect_path_buttons() -> void:
	flame_btn.pressed.connect(_on_path_selected.bind("flame"))
	frost_btn.pressed.connect(_on_path_selected.bind("frost"))
	ferment_btn.pressed.connect(_on_path_selected.bind("ferment"))


func _load_path(path_id: String) -> void:
	current_path = path_id
	title_label.text = paths[path_id]["title"]
	
	# Clear existing skill nodes
	for child in nodes.get_children():
		child.queue_free()
	skill_nodes.clear()
	skill_data.clear()
	
	# Create nodes for this path
	for node_data in paths[path_id]["nodes"]:
		_create_skill_node(node_data)
	
	# Update button styles based on unlock status
	_update_all_button_styles()
	
	lines.queue_redraw()
	description_box.visible = false


func _create_skill_node(data: Dictionary) -> void:
	var id = data["id"]
	var display_name = data["name"]
	var pos = data["pos"]
	var xp_cost = data["xp_cost"]
	var description = data["description"]
	
	# Create a container for the button and cost label
	var container = Control.new()
	container.position = pos - Vector2(50, 50)
	container.custom_minimum_size = Vector2(100, 100)
	
	# Create the main button
	var btn = Button.new()
	btn.text = display_name
	btn.custom_minimum_size = Vector2(100, 80)
	btn.position = Vector2(0, 0)
	btn.pressed.connect(_on_skill_selected.bind(id))
	btn.mouse_entered.connect(_on_skill_hover.bind(id))
	btn.mouse_exited.connect(_on_skill_hover_end)
	
	# Center the text
	btn.add_theme_constant_override("align", 1)
	
	container.add_child(btn)
	
	# Create XP cost label (bottom right of button)
	var cost_label = Label.new()
	if xp_cost > 0:
		cost_label.text = str(xp_cost) + " XP"

	cost_label.position = Vector2(5, 60)
	container.add_child(cost_label)
	
	nodes.add_child(container)
	
	# Store references
	skill_nodes[id] = btn
	skill_data[id] = {
		"xp_cost": xp_cost,
		"description": description,
		"container": container,
		"cost_label": cost_label
	}


func _update_all_button_styles() -> void:
	for skill_id in skill_nodes.keys():
		_update_button_style(skill_id)


func _update_button_style(skill_id: String) -> void:
	var btn = skill_nodes[skill_id]
	var data = skill_data[skill_id]
	var is_unlocked = is_skill_unlocked(skill_id)
	var can_purchase = can_purchase_skill(skill_id)
	
	if is_unlocked:
		btn.add_theme_stylebox_override("normal", style_unlocked)
		btn.add_theme_stylebox_override("hover", style_unlocked)
		btn.add_theme_stylebox_override("pressed", style_unlocked)
		data["cost_label"].text = "OWNED"
		data["cost_label"].add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	elif can_purchase:
		btn.add_theme_stylebox_override("normal", style_purchasable)
		btn.add_theme_stylebox_override("hover", style_purchasable)
		btn.add_theme_stylebox_override("pressed", style_purchasable)
		data["cost_label"].add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	else:
		btn.add_theme_stylebox_override("normal", style_locked)
		btn.add_theme_stylebox_override("hover", style_locked)
		btn.add_theme_stylebox_override("pressed", style_locked)
		data["cost_label"].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))


func is_skill_unlocked(skill_id: String) -> bool:
	if not unlocked_skills.has(current_path):
		return false
	return skill_id in unlocked_skills[current_path]


func can_purchase_skill(skill_id: String) -> bool:
	# Already unlocked
	if is_skill_unlocked(skill_id):
		return false
	
	# Define root skills that can be purchased without connections
	var root_skills = ["+10% Attack", "+10% Movement Speed", "+10% Health"]
	
	# If nothing is unlocked yet, only allow root skills
	if unlocked_skills[current_path].is_empty():
		if skill_id not in root_skills:
			return false
		# Check if player has enough XP
		var cost = skill_data[skill_id]["xp_cost"]
		return player_xp >= cost
	
	# Check if connected to an unlocked skill
	var has_unlocked_connection = false
	var connections = paths[current_path]["connections"]
	
	for connection in connections:
		if connection[1] == skill_id and is_skill_unlocked(connection[0]):
			has_unlocked_connection = true
			break
		if connection[0] == skill_id and is_skill_unlocked(connection[1]):
			has_unlocked_connection = true
			break
	
	if not has_unlocked_connection:
		return false
	
	# Check if player has enough XP
	var cost = skill_data[skill_id]["xp_cost"]
	return player_xp >= cost


func purchase_skill(skill_id: String) -> bool:
	if not can_purchase_skill(skill_id):
		return false
	
	var cost = skill_data[skill_id]["xp_cost"]
	
	# Deduct XP
	player_xp -= cost
	xp_label.text = "XP: " + str(player_xp)
	
	# Add to unlocked skills
	if not unlocked_skills.has(current_path):
		unlocked_skills[current_path] = []
	unlocked_skills[current_path].append(skill_id)
	
	# Apply the skill effect (you'll customize this)
	SkillSelection.apply_skill_effect(skill_id)
	
	# Update all button styles
	_update_all_button_styles()
	
	print("Purchased skill: ", skill_id, " for ", cost, " XP")
	return true



func _on_skill_hover(skill_id: String) -> void:
	if skill_data.has(skill_id):
		var data = skill_data[skill_id]
		var desc = data["description"]
		var cost = data["xp_cost"]
		var is_unlocked = is_skill_unlocked(skill_id)
		
		if is_unlocked:
			description_label.text = desc + "\n\n[OWNED]"
		elif can_purchase_skill(skill_id):
			description_label.text = desc + "\n\nCost: " + str(cost) + " XP\n[Click to purchase]"
		else:
			description_label.text = desc + "\n\nCost: " + str(cost) + " XP\n[Locked - unlock connected skill first]"
		
		description_box.visible = true
		
	# Prevents descrption box from going over the edge
	var viewport_size = get_viewport().get_visible_rect().size
	description_box.position = Vector2(
		viewport_size.x - description_box.size.x - 20, 
		viewport_size.y - description_box.size.y - 20
		)


func _on_skill_hover_end() -> void:
	description_box.visible = false


func show_menu() -> void:
	control.visible = true
	get_tree().paused = true
	xp_label.text = "XP: " + str(player_xp)
	_update_all_button_styles()
	lines.queue_redraw()


func hide_menu() -> void:
	control.visible = false
	get_tree().paused = false


func _on_path_selected(path_id: String) -> void:
	_load_path(path_id)


func _on_skill_selected(skill_id: String) -> void:
	print("Clicked skill: ", skill_id)
	
	if is_skill_unlocked(skill_id):
		print("Already unlocked!")
		return
	
	if can_purchase_skill(skill_id):
		purchase_skill(skill_id)
	else:
		print("Cannot purchase - either locked or not enough XP")


func _unhandled_input(event: InputEvent) -> void:
	if control.visible and event.is_action_pressed("escape_menu"):
		hide_menu()


func get_connections() -> Array:
	return paths[current_path]["connections"]


func get_skill_nodes() -> Dictionary:
	return skill_nodes


# Call this from your game when player collects XP
func add_xp(amount: int) -> void:
	player_xp += amount
	if xp_label:
		xp_label.text = "XP: " + str(player_xp)
