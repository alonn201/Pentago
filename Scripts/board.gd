extends Node2D
class_name Board

const Globals = preload("res://Scripts/globals.gd")

signal cell_click(island_index: int, cell_index: int)
signal island_turn_direction(island_index: int, direction: Globals.TurnDirection)

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
	emit_signal("cell_click", island_index, cell_index)
	return
	var island: Island = islands[island_index]
	var cell: Cell = island.cells[cell_index]
	if cell.type != Globals.CellType.EMPTY:
		cell.type = Globals.CellType.EMPTY
	else:
		cell.type = [Globals.CellType.WHITE, Globals.CellType.BLACK][x]
		x = (x + 1) % 2
	#print("island_index=", island_index, "\tcell_index=", cell_index)
	
	print(get_state())
	print(check_for_winners())
	
func _handle_island_turn_direction(island_index: int, direction: Globals.TurnDirection) -> void:
	emit_signal("island_turn_direction", island_index, direction)
	return
	var island: Island = islands[island_index]
	island.turn(direction)
	#print("island_index=", island_index, "\tdirection=", direction)

func _check_cells_streak(cell_types: Array) -> Globals.CellType:
	var count := 0
	var previous_cell_type := Globals.CellType.EMPTY
	for cell_type in cell_types:
		if cell_type == Globals.CellType.EMPTY:
			continue
			
		if cell_type == previous_cell_type:
			count += 1
			if count >= Globals.STREAK_TO_WIN:
				return cell_type
		else:
			count = 1
		previous_cell_type = cell_type
		
	
	return Globals.CellType.EMPTY

func get_state() -> Array:
	var top_left_cells: Array = islands[0].cells_type
	var top_right_cells: Array = islands[1].cells_type
	var bottom_left_cells: Array = islands[2].cells_type
	var bottom_right_cells: Array = islands[3].cells_type

	return [
		top_left_cells.slice(0, 3) + top_right_cells.slice(0, 3),
		top_left_cells.slice(3, 6) + top_right_cells.slice(3, 6),
		top_left_cells.slice(6, 9) + top_right_cells.slice(6, 9),
		
		bottom_left_cells.slice(0, 3) + bottom_right_cells.slice(0, 3),
		bottom_left_cells.slice(3, 6) + bottom_right_cells.slice(3, 6),
		bottom_left_cells.slice(6, 9) + bottom_right_cells.slice(6, 9),
	]

func check_for_winners() -> Globals.CellType:
	var state = get_state()
	var winner_type = Globals.CellType.EMPTY
	# Check rows
	for row in state:
		winner_type = _check_cells_streak(row)
		if winner_type != Globals.CellType.EMPTY:
			return winner_type
	
	# Check columns
	for col in range(state[0].size()):
		var column = []
		for row in state:
			column.append(row[col])
			winner_type = _check_cells_streak(column)
			if winner_type != Globals.CellType.EMPTY:
				return winner_type
	
	# Check diagonal
	var d1 = []
	var d2 = []
	for i in range(state.size()):
		d1.append(state[i][i]) # TL → BR
		d2.append(state[i][state.size() - 1 - i]) # TR → BL

	winner_type = _check_cells_streak(d1)
	if winner_type != Globals.CellType.EMPTY:
		return winner_type
		
	winner_type = _check_cells_streak(d2)
	if winner_type != Globals.CellType.EMPTY:
		return winner_type
	
	return Globals.CellType.EMPTY
	
