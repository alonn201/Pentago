extends Node2D
class_name Board

const Globals = preload("res://Scripts/globals.gd")

@onready var islands = $Islands.get_children()

var x := 0

func _ready() -> void:
	for i in islands.size():
		var island: Island = islands[i]
		island.cell_clicked.connect(func(cell_index: int):
			_handle_island_cell_clicked(i, cell_index)
		)
		
		island.turn_direction.connect(
			func(direction: Globals.TurnDirection):
				_handle_island_turn_direction(i, direction)
		)

func _handle_island_cell_clicked(island_index: int, cell_index: int) -> void:
	var island: Island = islands[island_index]
	var cell: Cell = island.cells[cell_index]
	cell.type = [Globals.CellType.WHITE, Globals.CellType.BLACK][x]
	x = (x + 1) % 2
	print("island_index=", island_index, "\tcell_index=", cell_index)

func _handle_island_turn_direction(island_index: int, direction: Globals.TurnDirection) -> void:
	print("island_index=", island_index, "\tdirection=", direction)
