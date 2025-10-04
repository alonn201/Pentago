extends Node2D
class_name Pentago

const Globals = preload("res://Scripts/globals.gd")
const ControlScene = preload("res://Scenes/control.tscn")

enum TurnState { OTHER, CELLS, TURN, WINNER }

@onready var board = $Board
@onready var cell_turn: Cell = $CellTurn

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var winner_label: Label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/WinnerLabel
@onready var restart_button: Button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/RestartButton
@onready var turn_label: Label = $TurnLabel


var player_turn := Globals.CellType.EMPTY
var turn_state := TurnState.OTHER

var this_cell_type := Globals.CellType.EMPTY
var other_cell_type := Globals.CellType.EMPTY

func _ready() -> void:
	board.cell_click.connect(_handle_cell_click)
	board.island_turn_direction.connect(_handle_island_turn)
	
	canvas_layer.hide()
	
	if is_multiplayer_authority():
		_handle_player_turn_assignment()
	else:
		restart_button.hide()
		
	get_tree().get_multiplayer().peer_disconnected.connect(_handle_disconnect)

func _handle_player_turn_assignment() -> void:
	var random_cell_type = (randi() % 2) + 1
	this_cell_type = Globals.CellType.values()[random_cell_type]
	other_cell_type = Globals.CellType.values()[3 - random_cell_type]
	
	rpc("rpc_sync_player2_cell_type", other_cell_type)
	rpc("rpc_sync_player_turn", Globals.CellType.WHITE)
	
func is_player_turn() -> bool:
	return player_turn == this_cell_type

func _handle_cell_click(island_index: int, cell_index: int) -> void:
	if (not is_player_turn() or turn_state != TurnState.CELLS):
		return
	
	var clicked_island: Island = board.islands[island_index]
	var clicked_cell: Cell = clicked_island.cells[cell_index]
	
	if (clicked_cell.type != Globals.CellType.EMPTY):
		return
	
	rpc("rpc_sync_cell", island_index, cell_index, this_cell_type)
	turn_state = TurnState.TURN

func _handle_island_turn(island_index: int, direction: Globals.TurnDirection) -> void:
	if (not is_player_turn() or turn_state != TurnState.TURN):
		return

	rpc("rpc_sync_island_turn", island_index, direction)
	rpc("rpc_sync_player_turn", other_cell_type)

func _set_winner(winner: Globals.CellType) -> void:
	if (turn_state == TurnState.WINNER):
		return
	
	turn_state = TurnState.WINNER
	canvas_layer.show()
	winner_label.text = str(Globals.CellType.keys()[winner]) + " won the game!"

func _on_restart_button_pressed() -> void:
	rpc("rpc_sync_restart")
	
func _handle_disconnect(id: int) -> void:
	Network.close()
	restart_button.hide()
	_set_winner(this_cell_type)
	print("disconnected ID=", id)

func _on_exit_button_pressed() -> void:
	Network.close()
	get_tree().quit()

func _on_back_button_pressed() -> void:
	Network.close()
	get_tree().change_scene_to_packed(ControlScene)

@rpc("any_peer")
func rpc_sync_player2_cell_type(cell_type: Globals.CellType) -> void:
	this_cell_type = cell_type
	other_cell_type = Globals.CellType.values()[3 - cell_type]

@rpc("any_peer", "call_local")
func rpc_sync_player_turn(turn: Globals.CellType) -> void:
	print("setting player turn: ", Globals.CellType.keys()[turn])
	player_turn = turn
	cell_turn.type = player_turn
	
	var is_local_turn = player_turn == this_cell_type
	
	turn_state = TurnState.CELLS if is_local_turn else TurnState.OTHER
	turn_label.text = ("Your turn" if is_local_turn else "Other's turn")
	
	# only master checks game state for winners
	if (is_multiplayer_authority()):
		var winner = board.check_for_winners()
		if (winner == Globals.CellType.EMPTY):
			return
		rpc("rpc_sync_winner", winner)

@rpc("any_peer", "call_local")
func rpc_sync_cell(island_index: int, cell_index: int, cell_type: Globals.CellType) -> void:
	board.islands[island_index].cells[cell_index].type = cell_type
	print("setting cell", "\t", "island_index=", island_index, "\t", "cell_index=", cell_index, "\t", "cell_type=", cell_type)

@rpc("any_peer", "call_local")
func rpc_sync_island_turn(island_index: int, direction: Globals.TurnDirection) -> void:
	var island: Island = board.islands[island_index]
	island.turn(direction)
	print("turning island", "\t", "island_index=", island_index, "\t", "direction=", direction)

@rpc("any_peer", "call_local")
func rpc_sync_winner(winner: Globals.CellType) -> void:
	_set_winner(winner)
	
@rpc("any_peer", "call_local")
func rpc_sync_restart() -> void:
	get_tree().reload_current_scene()
