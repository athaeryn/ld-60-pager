extends Node3D

class_name World

@export var player: Player
@onready var trigger_area: Area3D = $MeshInstance3D/Area3D

var messages = [
	[
		"       What!\nWhat are you doing\n  standing  on\n      that box?",
		"\n     AND\n    STAY OFF!!!!!!!"
	],
	[
		"   I thought I told you....\n        to STAY OFF\n    THAT BOX!!!",
		"\n      .....\n  ............\n     better stay off"
	],
]
var message_idx = 0

func _ready() -> void:
	player.set_pager_text("Current time:\n" + get_time_string() + "\nur doing gr8\n              Keep at it! :)")
	trigger_area.body_entered.connect(_on_trigger_entered)
	trigger_area.body_exited.connect(_on_trigger_exited)
	
func _on_trigger_entered(node: Node3D) -> void:
	if node is Player:
		var text = messages[min(message_idx,messages.size()-1)][0]
		node.set_pager_text(text)

func _on_trigger_exited(node: Node3D) -> void:
	if node is Player:
		var text = messages[min(message_idx,messages.size()-1)][1]
		node.set_pager_text(text)
		message_idx += 1

# Exit on Escape
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"): # "ui_cancel" is default Escape
		get_tree().quit()

func get_time_string():
	# Get current date and time as a dictionary
	var dt = Time.get_datetime_dict_from_system()
	
	# Format components into the desired string
	var formatted_time = "%02d:%02d %s             %02d/%02d/%02d" % [
		dt.hour % 12 if dt.hour % 12 != 0 else 12, # Convert to 12-hour
		dt.minute,
		"AM" if dt.hour < 12 else "PM",
		dt.month,
		dt.day,
		dt.year % 100 # Last two digits of year
	]
	
	return formatted_time
