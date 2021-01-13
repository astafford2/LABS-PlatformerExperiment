extends Level


var enemy_count := 0
var total_enemy_count := 0
onready var enemy_guage := $InfoHUDLayer/EnemyContainer/EnemyBar/HBoxContainer/Gauge


func _ready():
	player.enable_double_jump()
	player.enable_melee()
	player.enable_projectile()
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy_count += 1
		total_enemy_count += 1


func _process(_delta):
	enemy_guage.value = (float(enemy_count) / float(total_enemy_count)) * 100


func kill_enemy(body):
	body.queue_free()
	enemy_count -= 1


func _on_Player_enemy_hit(body):
	kill_enemy(body)
