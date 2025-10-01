extends Node2D
class_name Pentago

const Globals = preload("res://Scripts/globals.gd")

enum TurnState { OTHER, CELLS, TURN, WINNER }

@onready var board = $Board
@onready var cell_turn: Cell = $CellTurn

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var winner_label: Label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/WinnerLabel
@onready var restart_button: Button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/RestartButton


var player_turn := Globals.CellType.EMPTY
var turn_state := TurnState.CELLS

func _ready() -> void:
	board.cell_click.connect(_handle_cell_click)
	board.island_turn_direction.connect(_handle_island_turn)
	
	canvas_layer.hide()
	if (not is_multiplayer_authority()):
		restart_button.hide()
	
	if is_multiplayer_authority():
		_handle_player_turn_assignment()
		
func _update_player_turn(turn: Globals.CellType) -> void:
	player_turn = turn
	cell_turn.type = player_turn
	
	if (is_multiplayer_authority()):
		_check_for_winners()

func _set_player_turn(turn: Globals.CellType) -> void:
	_update_player_turn(turn)
	rpc("rpc_sync_player_turn", player_turn)
	print("setting player turn: ", Globals.CellType.keys()[Globals.CellType.values().find(player_turn)])

func _handle_player_turn_assignment() -> void:
	_set_player_turn(Globals.CellType.WHITE)
	
func is_player_turn() -> bool:
	return (is_multiplayer_authority() and player_turn == Globals.CellType.WHITE) \
	or (not is_multiplayer_authority() and player_turn == Globals.CellType.BLACK)

func _handle_cell_click(island_index: int, cell_index: int) -> void:
	if (not is_player_turn() or turn_state != TurnState.CELLS):
		return
	
	var clicked_island: Island = board.islands[island_index]
	var clicked_cell: Cell = clicked_island.cells[cell_index]
	
	if (clicked_cell.type != Globals.CellType.EMPTY):
		return
	
	var turns = [Globals.CellType.BLACK, Globals.CellType.WHITE]
	var current_turn_color = int(is_multiplayer_authority())
	var placed_type = turns[current_turn_color]
	_set_cell(island_index, cell_index, placed_type)
	turn_state = TurnState.TURN

func _set_cell(island_index: int, cell_index: int, cell_type: Globals.CellType) -> void:
	board.islands[island_index].cells[cell_index].type = cell_type
	rpc("rpc_sync_cell", island_index, cell_index, cell_type)
	print("setting cell", "island_index=", island_index, "\t", "cell_index=", cell_index, "\t", "cell_type=", cell_type)

func _handle_island_turn(island_index: int, direction: Globals.TurnDirection) -> void:
	if (not is_player_turn() or turn_state != TurnState.TURN):
		return

	_turn_island(island_index, direction)
	turn_state = TurnState.OTHER
	
	var turns = [Globals.CellType.BLACK, Globals.CellType.WHITE]
	var next_turn = turns[(int(is_multiplayer_authority()) + 1) % 2]
	_set_player_turn(next_turn)

func _turn_island(island_index: int, direction: Globals.TurnDirection) -> void:
	var island: Island = board.islands[island_index]
	island.turn(direction)
	rpc("rpc_sync_island_turn", island_index, direction)
	print("turning island ", "island_index=", island_index, "\t", "direction=", direction)

func _check_for_winners() -> void:
	var winner = board.check_for_winners()
	if (winner == Globals.CellType.EMPTY):
		return
	_set_winner(winner)
	rpc("rpc_sync_winner", winner)

func _set_winner(winner: Globals.CellType) -> void:
	turn_state = TurnState.WINNER
	canvas_layer.show()
	winner_label.text = str(Globals.CellType.keys()[Globals.CellType.values().find(winner)]) + " won the game!"

func _restart() -> void:
	get_tree().reload_current_scene()

func _on_restart_button_pressed() -> void:
	rpc("rpc_sync_restart")
	_restart()

@rpc("any_peer")
func rpc_sync_player_turn(turn: Globals.CellType) -> void:
	_update_player_turn(turn)
	print("setting player turn: ", Globals.CellType.keys()[Globals.CellType.values().find(player_turn)])

@rpc("any_peer")
func rpc_sync_cell(island_index: int, cell_index: int, cell_type: Globals.CellType) -> void:
	board.islands[island_index].cells[cell_index].type = cell_type
	turn_state = TurnState.CELLS
	print("setting cell", "island_index=", island_index, "\t", "cell_index=", cell_index, "\t", "cell_type=", cell_type)

@rpc("any_peer")
func rpc_sync_island_turn(island_index: int, direction: Globals.TurnDirection) -> void:
	var island: Island = board.islands[island_index]
	island.turn(direction)
	print("turning island", "island_index=", island_index, "\t", "direction=", direction)

@rpc("any_peer")
func rpc_sync_winner(winner: Globals.CellType) -> void:
	_set_winner(winner)
	
@rpc("any_peer")
func rpc_sync_restart() -> void:
	_restart()
