extends Control

@onready var fullscreen_button: CheckButton = $MarginContainer/VBoxContainer/FullscreenButton
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton
@onready var smoothing_button: CheckButton = $MarginContainer/VBoxContainer/VBoxContainer2/SmoothingButton


signal request_save;

func _ready():
	fullscreen_button._update();
	smoothing_button.set_pressed_no_signal(SettingsManager.camera_smoothing);

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


func _on_smoothing_button_toggled(toggled_on: bool) -> void:
	SettingsManager.camera_smoothing = toggled_on;
	request_save.emit()
