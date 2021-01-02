extends "Level.gd"


func _ready():
	player.enable_level_2()
	next_level_scene_path = "res://src/Level-3.tscn"
	traps_area = $TrapsArea
