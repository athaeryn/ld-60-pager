extends CharacterBody3D

class_name Player

@onready var head = $Head
@onready var eyes = $Head/Eyes
@onready var camera_3d = $Head/Eyes/PlayerCamera
@onready var standing_collider = $StandingCollider
@onready var crouching_collider = $CrouchingCollider
@onready var standup_check = $StandupCheck
@onready var hand = $Head/Hand


@export var pager: Pager


const SPEED_IDLE: float = 0.0
@export var SPEED_WALKING: float = 3.0
@export var SPEED_SPRINTING: float = 5.0
@export var SPEED_CROUCHING: float = 1.0
@export var CAMERA_SENSITIVITY: float = 0.2

const CAMERA_HEIGHT_STANDING := 1.85
const CAMERA_HEIGHT_CROUCHING := .85
const CAMERA_MAX_HEAD_UP := 85.0
const CAMERA_MAX_HEAD_DOWN := -80.0
const CAMERA_FOV_WALKING := 90.0
const CAMERA_FOV_CROUCHING := 75.0
const CAMERA_FOV_SPRINTING := 115.0
const JUMP_VELOCITY = 6.5

enum State {
	IDLE_STAND,
	IDLE_CROUCH,
	WALK_STANDING,
	WALK_CROUCHING,
	SPRINTING,
	AIR
}

var current_state := State.IDLE_STAND
var current_speed := SPEED_WALKING
var moving := false
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hand.position = Vector3(0, -0.2, 0)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		rotate_y(deg_to_rad(-Input.get_axis("look_left", "look_right") * CAMERA_SENSITIVITY * 4.0))
		head.rotate_x(deg_to_rad(-Input.get_axis("look_up", "look_down") * CAMERA_SENSITIVITY * 2.0))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(CAMERA_MAX_HEAD_DOWN), deg_to_rad(CAMERA_MAX_HEAD_UP))
	elif event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * CAMERA_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * CAMERA_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(CAMERA_MAX_HEAD_DOWN), deg_to_rad(CAMERA_MAX_HEAD_UP))


func _physics_process(delta):
	updatePlayerState()
	#updatePlayerCamera(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y += get_gravity().y * delta
		else:
			velocity.y += get_gravity().y * delta * 2.0
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var lerp_factor := 6.0 if moving else 10.0
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_factor)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)

	move_and_slide()
	
func set_pager_text(text: String) -> void:
	pager.set_text(text)

func set_pager_raised(raised: bool) -> void:
	if raised:
		hand.position = Vector3(0, 0, 0)
	else:
		hand.position = Vector3(0, -0.125, 0)

func updatePlayerState():
	moving = (input_dir != Vector2.ZERO)
	if not is_on_floor():
		current_state = State.AIR  
	else:
		if Input.is_action_pressed("crouch"):
			if not moving:
				current_state = State.IDLE_CROUCH
			else:
				current_state = State.WALK_CROUCHING
		elif !standup_check.is_colliding():
			if not moving:
				current_state = State.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				current_state = State.SPRINTING
			else:
				current_state = State.WALK_STANDING
				
	#updatePlayerCollider(current_state)
	updatePlayerSpeed(current_state)

func updatePlayerCollider(state):
	if state == State.IDLE_CROUCH or State.WALK_CROUCHING:
		standing_collider.disabled = true
		crouching_collider.disabled = false
	else:
		standing_collider.disabled = false
		crouching_collider.disabled = true



func updatePlayerSpeed(state):
	match state:
		State.IDLE_STAND or State.IDLE_CROUCH:
			current_speed = SPEED_IDLE
		State.WALK_STANDING:
			current_speed = SPEED_WALKING
		State.WALK_CROUCHING:
			current_speed = SPEED_CROUCHING
		State.SPRINTING:
			current_speed = SPEED_SPRINTING


func updatePlayerCamera(delta: float):
	match current_state:
		State.IDLE_STAND or State.WALK_STANDING:
			head.position.y = lerp(head.position.y, CAMERA_HEIGHT_STANDING, delta * 10.0)
			camera_3d.fov = lerp(camera_3d.fov, CAMERA_FOV_WALKING, delta * 10.0)
		State.IDLE_CROUCH or State.WALK_CROUCHING:
			head.position.y = lerp(head.position.y, CAMERA_HEIGHT_CROUCHING, delta * 10.0)
			camera_3d.fov = lerp(camera_3d.fov, CAMERA_FOV_CROUCHING, delta * 10.0)
		State.SPRINTING:
			head.position.y = lerp(head.position.y, CAMERA_HEIGHT_STANDING, delta * 10.0)
			camera_3d.fov = lerp(camera_3d.fov, CAMERA_FOV_SPRINTING, delta * 10.0)
