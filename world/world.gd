extends Node3D

class_name World

@export var player: Player

func _ready() -> void:
	player.set_pager_text(get_time_string())

# Exit on Escape
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"): # "ui_cancel" is default Escape
		get_tree().quit()

func get_time_string():
	# Get current date and time as a dictionary
	var dt = Time.get_datetime_dict_from_system()
	
	# Format components into the desired string
	var formatted_time = "%02d:%02d %s  %02d/%02d/%02d" % [
		dt.hour % 12 if dt.hour % 12 != 0 else 12, # Convert to 12-hour
		dt.minute,
		"AM" if dt.hour < 12 else "PM",
		dt.month,
		dt.day,
		dt.year % 100 # Last two digits of year
	]
	
	return formatted_time
