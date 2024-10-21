extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../CanvasGroup/double jump unlock/AnimationPlayer"
@onready var powerup_effect = $"../Player/Powerup Effect"
var powerup_recieved: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		if powerup_recieved == false:
			print("double jump on")
			Abilities.double_jump_enabled = true;
			player.double_jump_toggle = true; 
			$PowerupSFX.play()
			powerup_effect.emitting = true
			animation_player.play("double jump unlock appear");
			powerup_recieved = true
