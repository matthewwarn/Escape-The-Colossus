extends Node2D

signal spike_trap_player_died;

func _on_killzone_player_died() -> void:
	spike_trap_player_died.emit();
