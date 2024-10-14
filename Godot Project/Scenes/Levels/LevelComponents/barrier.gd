extends Node2D


func _on_heart_core_defeated() -> void:
	self.queue_free();


func _ready() -> void:
	if Global.core_one_defeated:
		self.queue_free();
