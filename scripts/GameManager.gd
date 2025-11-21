extends Node2D

var tutorial

func _ready():
	tutorial = get_tree().get_first_node_in_group("Tutorial")
	add_to_group("GameManager")
