extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../Player/Camera2D/Popup Text"
@onready var PowerupSFX: AudioStreamPlayer2D = $PowerupSFX

func _on_body_entered(body: Node2D) -> void:
	print("double jump on")
	PowerupSFX.play()
	player.double_jump_toggle = true;
	animation_player.play("doublejump");
