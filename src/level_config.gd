extends Resource
class_name LevelConfig

@export var level_name: String = "Level"

@export var spawn_fodder: bool = true
@export var spawn_bouncy: bool = true
@export var infinite_worm: bool = false

# Fodder settings
@export var spawn_interval: float = 1.0
@export var min_spawn_interval: float = 0.2
@export var interval_reduction: float = 0.03
@export var fodder_stop_time: float = 30.0
@export var fodder_resume_time: float = 120.0

# Worm settings
@export var worm_start_time: float = 60.0
@export var worm_interval: float = 45.0
@export var initial_worms_per_spawn: int = 1
@export var initial_dots_per_worm: int = 120

# Bouncy settings
@export var bouncy_start_time: float = 180.0
@export var bouncy_interval: float = 5.0
@export var bouncy_spawn_count: int = 3
@export var bouncy_health: int = 25

# Pair settings
@export var pair_start_time: float = -1.0 # -1 means disabled by default
@export var pair_interval: float = 12.0
@export var pair_spawn_count: int = 1

# Scaling settings
@export var scaling_interval: float = 80.0
@export var worm_count_multiplier: float = 2.0
@export var worm_scale_multiplier: float = 1.05
@export var dots_per_worm_multiplier: float = 1.25

# Grid settings
@export var initial_grid_extent: float = 800.0
@export var grid_expansion_interval: float = 150.0
@export var grid_expansion_multiplier: float = 1.5
