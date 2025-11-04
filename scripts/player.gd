extends CharacterBody2D


const SPEED = 75.0


func _physics_process(delta: float):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()
	
	if Input.is_action_pressed("down"):
		$AnimationPlayer.play("player_walk_down")
		
	if Input.is_action_pressed("up"):
		$AnimationPlayer.play("player_walk_up")
		
	if Input.is_action_pressed("left"):
		$AnimationPlayer.play("player_walk_left")
		
	if Input.is_action_pressed("right"):
		$AnimationPlayer.play("player_walk_right")
