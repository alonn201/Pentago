extends Node2D

const Globals = preload("res://Scripts/globals.gd")

signal turn_direction(direction: Globals.TurnDirection)

func _ready():
	$ClockWiseArrow.clicked.connect(func():
		emit_signal("turn_direction", Globals.TurnDirection.CLOCKWISE)
	)
	$CounterClockWiseArrow.clicked.connect(func():
		emit_signal("turn_direction", Globals.TurnDirection.COUNTERCLOCKWISE)
	)
