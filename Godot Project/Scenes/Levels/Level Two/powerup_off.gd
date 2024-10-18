extends Area2D

@onready var player: CharacterBody2D = $"../Player"

func _on_body_entered(body: Node2D) -> void:
	player.dash_toggle = false
