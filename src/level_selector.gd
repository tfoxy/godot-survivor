extends Control

const LevelConfigScript = preload("res://src/level_config.gd")

func _ready() -> void:
	# Center the UI
	set_anchors_preset(PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_CENTER)
	vbox.grow_horizontal = GROW_DIRECTION_BOTH
	vbox.grow_vertical = GROW_DIRECTION_BOTH
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.custom_minimum_size = Vector2(400, 0)
	add_child(vbox)
	
	var label = Label.new()
	label.text = "GODOT SURVIVOR"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", Color.CORAL)
	vbox.add_child(label)
	
	var sub_label = Label.new()
	sub_label.text = "SELECT YOUR CHALLENGE"
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(sub_label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(spacer)
	
	var btns = [
		{"name": "LEVEL 1", "level": 1, "color": Color.MEDIUM_SEA_GREEN},
		{"name": "LEVEL 2", "level": 2, "color": Color.INDIAN_RED},
		{"name": "LEVEL 3", "level": 3, "color": Color.MEDIUM_PURPLE},
		{"name": "LEVEL 4", "level": 4, "color": Color.CORNFLOWER_BLUE}
	]
	
	for b_info in btns:
		var btn = Button.new()
		btn.text = b_info.name
		btn.add_theme_font_size_override("font_size", 32)
		btn.add_theme_color_override("font_color", b_info.color)
		btn.pressed.connect(_on_level_selected.bind(b_info.level))
		btn.custom_minimum_size = Vector2(0, 80)
		vbox.add_child(btn)
		
		var b_spacer = Control.new()
		b_spacer.custom_minimum_size = Vector2(0, 20)
		vbox.add_child(b_spacer)

func _on_level_selected(level: int) -> void:
	var config = LevelConfigScript.new()
	if level == 1:
		config.level_name = "Level 1"
		config.spawn_fodder = true
		config.spawn_bouncy = true
		config.bouncy_health = 8
		config.bouncy_start_time = 180.0
		# Default values are already Level 1
	elif level == 2:
		config.level_name = "Level 2"
		config.spawn_fodder = true
		config.spawn_bouncy = true
		config.spawn_interval = 0.5
		config.worm_start_time = 30.0
		config.bouncy_start_time = 60.0
		config.bouncy_health = 8
		config.fodder_resume_time = 95.0
		config.initial_grid_extent = 1200.0
	elif level == 3:
		config.level_name = "Level 3"
		config.infinite_worm = true
		config.worm_start_time = 2.0
		config.worm_interval = 40.0
		config.initial_worms_per_spawn = 1
		config.initial_grid_extent = 300.0
		config.grid_expansion_interval = 10.0
		config.grid_expansion_multiplier = 1.05
	elif level == 4:
		config.level_name = "Level 4"
		config.spawn_fodder = true
		config.spawn_bouncy = true
		config.bouncy_start_time = 10.0
		config.pair_start_time = 2.0
		config.pair_interval = 5.0
		config.mortar_start_time = 5.0
		config.mortar_interval = 25.0
		config.initial_grid_extent = 800.0
	
	Globals.selected_level = config
	get_tree().change_scene_to_file("res://src/main.tscn")
