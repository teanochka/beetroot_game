extends Node
@onready var error_sound: AudioStreamPlayer = $Error
@onready var placed_sound: AudioStreamPlayer = $Placed
@onready var bought_sound: AudioStreamPlayer = $Bought

func play_error() -> void:
	if error_sound:
		error_sound.play()

func play_placed() -> void:
	if placed_sound:
		placed_sound.play()

func play_bought() -> void:
	if bought_sound:
		bought_sound.play()
