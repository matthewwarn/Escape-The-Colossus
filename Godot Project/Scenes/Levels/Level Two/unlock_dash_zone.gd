extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var animation: AnimationPlayer = $"../CanvasLayer/Dash unlock/AnimationPlayer"
@onready var animation2: AnimationPlayer = $"../CanvasLayer/Press z/AnimationPlayer"


func _on_body_entered(_body):
	print("You just entered.")
	animation.play("dash unlock appear")
	animation2.play("press z appear")
