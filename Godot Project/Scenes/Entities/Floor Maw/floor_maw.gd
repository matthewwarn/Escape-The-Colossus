extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
signal player_died;

func _on_proximity_detector_body_entered(_body: Node2D) -> void:
	animated_sprite_2d.play(&"Spawn")


func _on_proximity_detector_body_exited(body: Node2D) -> void:
	animated_sprite_2d.play_backwards(&"Spawn");


func _on_killzone_player_died() -> void:
	player_died.emit();


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == &"Spawn":
		# check whether the spawn animation was played backwards
		if animated_sprite_2d.frame == 0:
			animated_sprite_2d.play(&"Unspawned");
		else:
			animated_sprite_2d.play(&"Active");
