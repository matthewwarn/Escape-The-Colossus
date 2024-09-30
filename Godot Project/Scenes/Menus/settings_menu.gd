extends Control

signal return_to_main;


func _on_return_button_pressed() -> void:
	return_to_main.emit();
