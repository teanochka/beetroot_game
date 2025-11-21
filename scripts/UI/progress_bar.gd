extends Node2D

@onready var texture_progress: TextureProgressBar = $TextureProgressBar

func update_progress(percent: float):
	texture_progress.value = percent
	
func get_progress() -> float:
	return texture_progress.value
