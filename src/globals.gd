extends Node

const LevelConfigScript = preload("res://src/level_config.gd")

var GRID_EXTENT: float = 800.0
var highest_time: float = 0.0
var selected_level: Resource = null # Use Resource to be safer or the preloaded script name
