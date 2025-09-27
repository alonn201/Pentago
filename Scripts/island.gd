extends Node2D

signal turn_direction(direction: int)

@export var show_top_left: bool = false
@export var show_top_right: bool = false
@export var show_bottom_left: bool = false
@export var show_bottom_right: bool = false


func _ready() -> void:
	$TurnDirections/TopLeft.visible = show_top_left
	$TurnDirections/TopRight.visible = show_top_right
	$TurnDirections/BottomLeft.visible = show_bottom_left
	$TurnDirections/BottomRight.visible = show_bottom_right


func _on_top_left_turn_direction(direction: int) -> void:
	emit_signal("turn_direction", direction)

func _on_top_right_turn_direction(direction: int) -> void:
	emit_signal("turn_direction", direction)

func _on_bottom_right_turn_direction(direction: int) -> void:
	emit_signal("turn_direction", direction)

func _on_bottom_left_turn_direction(direction: int) -> void:
	emit_signal("turn_direction", direction)
