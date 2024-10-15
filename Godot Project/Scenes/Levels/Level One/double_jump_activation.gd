extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../Player/Camera2D/Popup Text"

var powerup_recieved: bool = false

func _on_body_entered(body: Node2D) -> void:
	if powerup_recieved == false:
		print("double jump on")
		Abilities.double_jump_enabled = true;
		player.double_jump_toggle = true;
		$PowerupSFX.play()
		animation_player.play("doublejump");
		powerup_recieved = true
