extends Control

@onready var fullscreen_button: CheckButton = $MarginContainer/VBoxContainer/FullscreenButton
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton
@onready var smoothing_button: CheckButton = $MarginContainer/VBoxContainer/SmoothingButtonContainer/SmoothingButton
@onready var speedrun_button: CheckButton = $MarginContainer/VBoxContainer/SpeedrunButton

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
	
	if speedrun_button != null:
		speedrun_button.set_pressed_no_signal(SettingsManager.speedrun_timer)


func _on_fullscreen_button_request_save() -> void:
	request_save.emit();


func _on_smoothing_button_toggled(toggled_on: bool) -> void:
	SettingsManager.camera_smoothing = toggled_on;
	request_save.emit()


func _on_speedrun_button_toggled(toggled_on: bool) -> void:
	SettingsManager.speedrun_timer = toggled_on;
