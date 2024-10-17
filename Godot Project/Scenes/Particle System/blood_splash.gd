extends Node2D

@onready var particles = $CPUParticles2D

func start_emitting():
	particles.emitting = true


func stop_emitting():
	particles.emitting = false
