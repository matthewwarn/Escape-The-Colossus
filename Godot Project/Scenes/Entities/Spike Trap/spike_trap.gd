extends Node2D

signal player_died;

func _on_killzone_player_died() -> void:
	player_died.emit();
