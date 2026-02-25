# Godot build configuration for size optimization.
# See: https://docs.godotengine.org/en/stable/engine_details/development/compiling/optimizing_for_size.html

optimize = "size"
use_lto = "yes"
debug_symbols = "no"

# Disabling unused modules
module_text_server_adv_enabled = "no"
module_text_server_fb_enabled = "yes"
module_3d_enabled = "no"
module_physics_3d_enabled = "no"
module_physics_2d_enabled = "yes"
module_navigation_enabled = "no"
module_mobile_vr_enabled = "no"
module_openxr_enabled = "no"
module_meshoptimizer_enabled = "no"
module_minimp3_enabled = "no"
module_msdfgen_enabled = "no"
module_raycast_enabled = "no"
module_regex_enabled = "yes" # Keep regex, often useful
module_svg_enabled = "yes" # Keep SVG for icons
module_uastc_enabled = "no"

# Disabling advanced features
disable_advanced_gui = "yes"
disable_3d = "yes"

