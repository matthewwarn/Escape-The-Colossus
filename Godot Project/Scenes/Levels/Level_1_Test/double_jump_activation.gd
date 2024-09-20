extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../Player/Camera2D/AnimationPlayer"

func _on_body_entered(body: Node2D) -> void:
	print("double jump")
	player.double_jump_toggle = true;
	animation_player.play("doublejump");
