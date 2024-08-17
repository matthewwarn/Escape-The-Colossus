extends Area2D

signal level_transition_reached;

# Ensure that the player collision layer is 2 
func _on_body_entered(body: Node2D) -> void:
	print("Level transition reached")
	level_transition_reached.emit();
