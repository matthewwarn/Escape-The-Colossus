extends Node2D


@onready var particles = $CPUParticles2D
#@onready var area_2d = $Area2D

func is_emitting():
	particles.emitting = true


func is_not_emitting():
	particles.emitting = false
