extends Node2D

signal player_died;

func _ready():
	var level_root = get_node("/root/GameManager/TemplateLevel")


func _on_acid_tile_player_died() -> void:
	player_died.emit();
