extends Node2D

signal player_died;

func _on_acid_tile_player_died() -> void:
	player_died.emit();
