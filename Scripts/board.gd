extends Node2D


func _on_top_left_turn_direction(direction: int) -> void:
	self._handle_island_turn_direction(0, direction)

func _on_top_right_turn_direction(direction: int) -> void:
	self._handle_island_turn_direction(1, direction)

func _on_bottom_left_turn_direction(direction: int) -> void:
	self._handle_island_turn_direction(2, direction)

func _on_bottom_right_turn_direction(direction: int) -> void:
	self._handle_island_turn_direction(3, direction)

func _handle_island_turn_direction(index: int, direction: int) -> void:
	print("island=", index, "direction=", direction)
