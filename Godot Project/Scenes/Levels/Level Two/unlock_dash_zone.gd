extends Area2D

var messageShown = false

@onready var player: CharacterBody2D = $"../Player"
@onready var animation: AnimationPlayer = $"../CanvasLayer/Dash unlock/AnimationPlayer"
@onready var animation2: AnimationPlayer = $"../CanvasLayer/Press z/AnimationPlayer"

func _on_body_entered(_body):
	if not messageShown:
		print("Dash on")
		player.dash_toggle = true
		animation.play("dash unlock appear")
		animation2.play("press z appear")
		messageShown = true
	
