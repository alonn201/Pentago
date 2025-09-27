extends Node2D

signal turn_direction(direction: int)

func _ready():
	$ClockWiseArrow.clicked.connect(func(): emit_signal("turn_direction", 1))
	$CounterClockWiseArrow.clicked.connect(func(): emit_signal("turn_direction", -1))
