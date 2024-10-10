extends Area2D

@export var spawn_position : Vector2

signal checkpoint_activated(spawn_position)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		Global.checkpoint_reached = true
		Global.checkpoint_position = spawn_position
		print("checkpoint reached")
