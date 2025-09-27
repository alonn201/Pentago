extends Node2D

const Globals = preload("res://Scripts/globals.gd")


func _ready():
	for i in range($Islands.get_child_count()):
		var island = $Islands.get_child(i)
		island.turn_direction.connect(func(direction): _handle_island_turn_direction(i, direction))

func _handle_island_turn_direction(index: int, direction: Globals.TurnDirection) -> void:
	print("island=", index, "direction=", direction)
