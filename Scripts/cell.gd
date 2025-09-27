extends Node2D

const Globals = preload("res://Scripts/globals.gd")

signal clicked

func _ready():
	$Area2D.input_event.connect(_on_area_input_event)
		
func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked")
		
var cell_type: Globals.CellType:
	get:
		if $Sprite.animation == "white":
			return Globals.CellType.WHITE
		elif $Sprite.animation == "black":
			return Globals.CellType.BLACK
		return Globals.CellType.EMPTY
	set(value):
		match value:
			Globals.CellType.WHITE:
				$Sprite.animation = "white"
			Globals.CellType.BLACK:
				$Sprite.animation = "black"
			Globals.CellType.EMPTY:
				$Sprite.animation = "empty"
