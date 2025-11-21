extends CharacterBody2D
@onready var walking_sound: AudioStreamPlayer = $Walking

const SPEED = 75.0
var current_movement_state: int = 0
enum MovementState { IDLE, MOVING }

func _physics_process(delta: float):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()
	
	# Управление анимациями
	if Input.is_action_pressed("down"):
		$AnimationPlayer.play("player_walk_down")
	elif Input.is_action_pressed("up"):
		$AnimationPlayer.play("player_walk_up")
	elif Input.is_action_pressed("left"):
		$AnimationPlayer.play("player_walk_left")
	elif Input.is_action_pressed("right"):
		$AnimationPlayer.play("player_walk_right")
	
	var wants_to_move = direction.length() > 0
	var new_state = MovementState.MOVING if wants_to_move else MovementState.IDLE
	
	if new_state != current_movement_state:
		match new_state:
			MovementState.MOVING:
				start_walking_sound()
			MovementState.IDLE:
				stop_walking_sound()
		
		current_movement_state = new_state

func start_walking_sound():
	if walking_sound and not walking_sound.playing:
		walking_sound.play()

func stop_walking_sound():
	if walking_sound and walking_sound.playing:
		walking_sound.stop()
