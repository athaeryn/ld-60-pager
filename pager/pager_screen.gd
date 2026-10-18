extends MarginContainer

class_name PagerScreen

@onready var label: Label = $Label


func set_text(text: String) -> void:
	label.text = text
