extends "Level.gd"


var enemy_count := 0
onready var enemy_count_label := $InfoHUDLayer/EnemyCountLabel


func _ready():
	player.enable_level_3()
	next_level_scene_path = "res://src/Level-4.tscn"
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy_count += 1


func _process(_delta):
	
	enemy_count_label.text = "Enemies left: " + str(enemy_count)
	
	if enemy_count <= 0:
		win_player()


func kill_enemy(body):
	body.queue_free()
	enemy_count -= 1


func _on_Player_enemy_hit(body):
	kill_enemy(body)
