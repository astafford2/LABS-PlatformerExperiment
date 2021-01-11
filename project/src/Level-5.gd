extends Level


func _ready():
	pass


func _on_LevelEndArea_body_entered(body):
	if body == player:
		win_player()
