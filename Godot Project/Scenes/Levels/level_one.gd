extends Node2D

# Signals connected to the game manager to control level loading.
signal level_reset_requested;
signal next_level_requested;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Connect all killzones to this method.
func _on_player_died() -> void:
	print("death relayed")
	level_reset_requested.emit();

# Connect the area2d level transition trigger to this method.
func _on_level_transition_reached() -> void:
	print("level transition relayed")
	next_level_requested.emit();
