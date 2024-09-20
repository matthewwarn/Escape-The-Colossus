extends Area2D

# Get reference to the timer using a path
@onready var timer = $DeathTimer;

signal player_died;

# Make sure collision mask is set to layer 2
func _on_body_entered(body):
	if body.name == "Player":
		print('death triggered');
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

# Player death will be requested when the death timer times out.
func _on_timer_timeout():
	print("death timeout")
	player_died.emit();
