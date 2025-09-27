extends Node2D
class_name Island

const Globals = preload("res://Scripts/globals.gd")

signal cell_clicked(cell_index: int)
signal turn_direction(direction: Globals.TurnDirection)

@export var show_top_left: bool = false
@export var show_top_right: bool = false
@export var show_bottom_left: bool = false
@export var show_bottom_right: bool = false

@onready var cells = $Cells.get_children()

func _ready() -> void:
	$TurnDirections/TopLeft.visible = show_top_left
	$TurnDirections/TopRight.visible = show_top_right
	$TurnDirections/BottomLeft.visible = show_bottom_left
	$TurnDirections/BottomRight.visible = show_bottom_right
	
	for turn_arrows in $TurnDirections.get_children():
		turn_arrows.turn_direction.connect(
			func(direction: Globals.TurnDirection):
				emit_signal("turn_direction", direction)
		)

	for i in cells.size():
		var cell: Cell = cells[i]
		cell.clicked.connect(func(): emit_signal("cell_clicked", i))
