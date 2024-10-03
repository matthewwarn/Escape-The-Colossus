extends Control

@onready var fullscreen_button: CheckButton = $MarginContainer/VBoxContainer/FullscreenButton
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton

signal request_save;

func _on_return_button_pressed() -> void:
	hide();

func _on_visibility_changed() -> void:
	if return_button != null:
		if visible:
			return_button.grab_focus();
	if fullscreen_button != null:
		fullscreen_button._update();


func _on_fullscreen_button_request_save() -> void:
	request_save.emit();
