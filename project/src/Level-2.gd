extends Level


func _ready():
	player.enable_double_jump()
	next_scene_path = "res://src/Level-3.tscn"
	traps_area = $TrapsArea
