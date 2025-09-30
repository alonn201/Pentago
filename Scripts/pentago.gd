extends Node2D
class_name Pentago

const Globals = preload("res://Scripts/globals.gd")

@onready var board = $Board

var player_turn := Globals.CellType.EMPTY
var was_previous_turn := false

func _ready() -> void:
	board.cell_click.connect(_handle_board_click)
	
	if is_multiplayer_authority():
		_handle_player_turn_assignment()

func _set_player_turn(turn: Globals.CellType) -> void:
	player_turn = turn
	rpc("rpc_sync_player_turn", player_turn)
	print("setting player turn: ", Globals.CellType.keys()[Globals.CellType.values().find(player_turn)])

func _handle_player_turn_assignment() -> void:
	_set_player_turn(Globals.CellType.WHITE)
	
func is_player_turn() -> bool:
	return (is_multiplayer_authority() and player_turn == Globals.CellType.WHITE) \
	or (not is_multiplayer_authority() and player_turn == Globals.CellType.BLACK)


func _handle_board_click(island_index: int, cell_index: int) -> void:
	if (not is_player_turn() or was_previous_turn):
		return
	
	var clicked_island: Island = board.islands[island_index]
	var clicked_cell: Cell = clicked_island.cells[cell_index]
	
	if (clicked_cell.type != Globals.CellType.EMPTY):
		return
	
	var turns = [Globals.CellType.BLACK, Globals.CellType.WHITE]
	var current_turn_color = int(is_multiplayer_authority())
	var placed_type = turns[current_turn_color]
	_set_cell(island_index, cell_index, placed_type)
	was_previous_turn = true
	_set_player_turn(turns[(current_turn_color + 1) % 2])

func _set_cell(island_index: int, cell_index: int, cell_type: Globals.CellType) -> void:
	board.islands[island_index].cells[cell_index].type = cell_type
	rpc("rpc_sync_cell", island_index, cell_index, cell_type)
	print("setting cell", "island_index=", island_index, "\t", "cell_index=", cell_index, "\t", "cell_type=", cell_type)

@rpc("any_peer")
func rpc_sync_player_turn(turn: Globals.CellType) -> void:
	player_turn = turn
	print("setting player turn: ", Globals.CellType.keys()[Globals.CellType.values().find(player_turn)])

@rpc("any_peer")
func rpc_sync_cell(island_index: int, cell_index: int, cell_type: Globals.CellType) -> void:
	board.islands[island_index].cells[cell_index].type = cell_type
	was_previous_turn = false
	print("setting cell", "island_index=", island_index, "\t", "cell_index=", cell_index, "\t", "cell_type=", cell_type)
