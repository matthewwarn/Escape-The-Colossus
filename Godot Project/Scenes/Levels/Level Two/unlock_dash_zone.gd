extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var label_animation: AnimationPlayer = $"../Player/Camera2D/Label animation"


func _on_body_entered(_body):
	print("You just entered.")
	Abilities.dash_enabled = true;
	label_animation.play("dash_unlock")
