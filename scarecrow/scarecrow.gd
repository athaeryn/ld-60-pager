extends Node3D

class_name Scarecrow
@onready var animation_player = $AnimationPlayer

func play_kill_animation() -> void:
	animation_player.play("Scarecrow/KILL")
