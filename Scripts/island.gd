extends Node2D

const Globals = preload("res://Scripts/globals.gd")

signal turn_direction(direction: Globals.TurnDirection)

@export var show_top_left: bool = false
@export var show_top_right: bool = false
@export var show_bottom_left: bool = false
@export var show_bottom_right: bool = false


func _ready() -> void:
	$TurnDirections/TopLeft.visible = show_top_left
	$TurnDirections/TopRight.visible = show_top_right
	$TurnDirections/BottomLeft.visible = show_bottom_left
	$TurnDirections/BottomRight.visible = show_bottom_right
	
	for turn_arrows in $TurnDirections.get_children():
		turn_arrows.turn_direction.connect(func(direction): emit_signal("turn_direction", direction))
