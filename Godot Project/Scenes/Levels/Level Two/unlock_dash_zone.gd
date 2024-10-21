extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation: AnimationPlayer = $"../CanvasLayer/Dash unlock/AnimationPlayer"
@onready var animation2: AnimationPlayer = $"../CanvasLayer/Press z/AnimationPlayer"
@onready var powerup_effect = $"../Player/Powerup Effect"

var entered = false


func _on_body_entered(_body):
	if not entered:
		animation.play("dash unlock appear")
		animation2.play("press z appear")
		Abilities.dash_enabled = true;
		powerup_effect.emitting = true;
		entered = true;
	
	
