extends Node

signal tutorial_task_completed(task_type: String)

signal current_task_changed(task_type: String)

func emit_current_task_changed(task_type: String):
	current_task_changed.emit(task_type)
	print("Event bus sending task changed")

func emit_task_completed(task_type: String):
	tutorial_task_completed.emit(task_type)
