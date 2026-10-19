extends Node3D

class_name World

@export var player: Player
@export var scarecrow: Scarecrow
@onready var trigger_area: Area3D = $MeshInstance3D/Area3D
@onready var pager_pickup_area_3d: Area3D = $PagerPickupArea3D
@onready var pager_on_counter = $pager
@onready var house_area_3d: Area3D = $HouseArea3D

@export var message_triggers : Array[Area3D]

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
var picked_up_pager = false

func _ready() -> void:
	for t in message_triggers:
		t.monitoring = false
		t.body_entered.connect(_on_message_trigger.bind(t))
		
	#player.set_pager_text("Current time:\n" + get_time_string() + "\nur doing gr8\n              Keep at it! :)")
	trigger_area.body_entered.connect(_on_trigger_entered)
	trigger_area.body_exited.connect(_on_trigger_exited)
	pager_pickup_area_3d.body_entered.connect(_pick_up_pager)
	house_area_3d.body_exited.connect(scarecrow_kill_sequence)
	
func _on_message_trigger(node: Node3D, area: Area3D) -> void:
	if node is Player:
		var text = area.get_meta("message")
		player.set_pager_text(text)
	
func _pick_up_pager(node: Node3D) -> void:
	if node is Player and !picked_up_pager:
		picked_up_pager = true
		print("pick up")
		pager_on_counter.queue_free()
		pager_pickup_area_3d.queue_free()
		player.set_pager_raised(true)
		player.set_pager_text("I'm coming to get you\n  hee hee hee heeee\n      >:}")
		for t in message_triggers:
			t.monitoring = true

func scarecrow_kill_sequence(node: Node3D) -> void:
	if node is Player:
		player.set_controlled(true)
		player.set_pager_raised(false)
		scarecrow.global_position = player.global_position + player.global_basis.z * -1.0
		scarecrow.look_at(player.global_position, Vector3.UP)
		scarecrow.play_kill_animation()

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
