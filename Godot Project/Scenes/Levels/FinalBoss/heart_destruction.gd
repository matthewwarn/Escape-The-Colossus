extends Area2D

@onready var tilemap = get_node("/root/TemplateLevel/TileMapLayer")

signal heart_destroyed_signal

var player_in_range: bool = false
var heart_hits: int = 0
var heart_destroyed: bool = false

func _ready():
	pass
	
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true


func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false


func _on_player_attack_made():
	if player_in_range and not heart_destroyed:
		heart_hits += 1
		#squishy blood sound effect
		
		if heart_hits >= 3:
			$CollisionShape2D.set_deferred("disabled", true)
			get_parent().visible = false
			tilemap.set_cell(Vector2(-7, -117), -1)
			emit_signal("heart_destroyed_signal")
