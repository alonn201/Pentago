extends Node2D

signal clicked

func _ready():
	$Area2D.input_event.connect(_on_area_input_event)
		
func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked")
