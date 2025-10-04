extends Node2D
class_name Island

const Globals = preload("res://Scripts/globals.gd")

signal cell_clicked(cell_index: int)
signal turn_direction(direction: Globals.TurnDirection)

@export var show_top_left: bool = false
@export var show_top_right: bool = false
@export var show_bottom_left: bool = false
@export var show_bottom_right: bool = false

@onready var turn_sound: AudioStreamPlayer2D = $TurnSound
@onready var cells = $Cells.get_children()

var cells_type: Array:
	get:
		return cells.map(func(c): return c.type)

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
		
func normalize_cells() -> Array:
	return [
		cells.slice(0, 3),
		cells.slice(3, 6),
		cells.slice(6, 9)
	]

func turn(direction: Globals.TurnDirection) -> void:
	var normalized_cells = normalize_cells()
	var turned_cells = _turn_array(normalized_cells, direction)
	var turned_types: Array[Globals.CellType] = []
	for i in range(3):
			for j in range(3):
				turned_types.append(turned_cells[i][j].type)
	
	for i in cells.size():
		cells[i].type = turned_types[i]
		
	turn_sound.play(0.20)
	await get_tree().create_timer(0.35).timeout
	turn_sound.stop() 

func _turn_array(arr: Array, direction: Globals.TurnDirection) -> Array:
	var n = arr.size()
	var turned_arr = []
	
	for i in range(n):
		var row = []
		row.resize(arr[i].size())
		turned_arr.append(row)

	match direction:
		Globals.TurnDirection.CLOCKWISE:
			for i in range(n):
				for j in range(arr[i].size()):
					turned_arr[j][n - 1 - i] = arr[i][j]

		Globals.TurnDirection.COUNTERCLOCKWISE:
			for i in range(n):
				for j in range(arr[i].size()):
					turned_arr[arr[i].size() - 1 - j][i] = arr[i][j]

	return turned_arr
