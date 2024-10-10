extends Control

@onready var fullscreen_button: CheckButton = $MarginContainer/VBoxContainer/FullscreenButton
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton

func _on_return_button_pressed() -> void:
	hide();

func _on_visibility_changed() -> void:
	if return_button != null:
		if visible:
			return_button.grab_focus();
	if fullscreen_button != null:
		fullscreen_button._update();
