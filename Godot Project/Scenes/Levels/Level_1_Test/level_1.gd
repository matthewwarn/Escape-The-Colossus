extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Player")
	player.double_jump_toggle = false
	player.dash_toggle = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
