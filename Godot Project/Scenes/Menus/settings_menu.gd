extends Control

@onready var fullscreen_button: CheckButton = $MarginContainer/VBoxContainer/FullscreenButton

func _on_return_button_pressed() -> void:
	hide();


func _on_visibility_changed() -> void:
	if fullscreen_button != null:
		fullscreen_button._update();
