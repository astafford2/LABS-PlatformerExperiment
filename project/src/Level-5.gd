extends Level


onready var souls_guage := $InfoHUDLayer/SoulBar/Guage

func _ready():
	pass


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		souls_guage.value += 10
	elif Input.is_action_just_pressed("ui_down"):
		souls_guage.value -= 10


func _on_LevelEndArea_body_entered(body):
	if body == player:
		win_player()
