extends Area2D

var messageShown = false 

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../CanvasGroup/double jump unlock/AnimationPlayer"

func _on_body_entered(body: Node2D) -> void:
	if not messageShown:
		print("Double jump on")
		player.double_jump_toggle = true
		animation_player.play("double jump unlock appear")
		messageShown = true
	
	
