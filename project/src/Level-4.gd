extends Level


var enemy_count := 0
onready var enemy_count_label := $InfoHUDLayer/EnemyCountLabel


onready var secrets_tilemap := $Secrets


func _ready():
	player.enable_level_4()
	instructions_popup.popup()
	next_scene_path = "res://src/CongratsScreen.tscn"
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy_count += 1


func _process(_delta):
	enemy_count_label.text = "Enemies left: " + str(enemy_count)
	soul_count_label.text = "Souls collected: " + str(soul_count)
	
	if enemy_count <= 0:
		win_player()


func kill_enemy(body):
	body.queue_free()
	enemy_count -= 1


func _on_Player_enemy_hit(body):
	kill_enemy(body)


func _on_SecretsArea2D_body_entered(body):
	if body == player:
		secrets_tilemap.visible = false
		player_cam.limit_bottom = 1050
		player_cam.drag_margin_top = 0.5
		player_cam.drag_margin_v_enabled = true


func _on_SecretsArea2D_body_exited(body):
	if body == player:
		secrets_tilemap.visible = true
		player_cam.limit_bottom = 1
		player_cam.drag_margin_v_enabled = false


func _on_ContinueButton_pressed():
	var _ignored = get_tree().change_scene(next_scene_path)

