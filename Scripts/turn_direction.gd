extends Node2D
class_name TurnDirection

const Globals = preload("res://Scripts/globals.gd")

signal turn_direction(direction: Globals.TurnDirection)

func _ready() -> void:
	$ClockWiseArrow.clicked.connect(func():
		emit_signal("turn_direction", Globals.TurnDirection.CLOCKWISE)
	)
	$CounterClockWiseArrow.clicked.connect(func():
		emit_signal("turn_direction", Globals.TurnDirection.COUNTERCLOCKWISE)
	)
