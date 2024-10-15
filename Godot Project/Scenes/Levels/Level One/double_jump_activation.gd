extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../CanvasGroup/double jump unlock/AnimationPlayer"

var powerup_recieved: bool = false

func _on_body_entered(body: Node2D) -> void:
	if powerup_recieved == false:
		print("double jump on")
		Abilities.double_jump_enabled = true;
		player.double_jump_toggle = true;
		$PowerupSFX.play()
		animation_player.play("double jump unlock appear");
		powerup_recieved = true
