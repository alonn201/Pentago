extends Node2D
class_name Island

const Globals = preload("res://Scripts/globals.gd")

const ROTATION_STEP := 90
const TURN_ANIMATION_DURATION := 0.75

signal cell_clicked(cell_index: int)
signal turn_direction(direction: Globals.TurnDirection)

@export var show_top_left: bool = false
@export var show_top_right: bool = false
@export var show_bottom_left: bool = false
@export var show_bottom_right: bool = false

@onready var body = $Body
@onready var cells = $Body/Cells.get_children()
@onready var turn_sound: AudioStreamPlayer2D = $TurnSound

var tween: Tween = null

var rotation_state := 0

var cells_type: Array:
	get:
		return cells.map(func(c): return c.type)

var normalized_cells_type: Array:
	get:
		return normalize_cells().map(func(row):
			return row.map(func(c):
				return c.type
			)
		)

var normalized_cells_type_flat: Array:
	get:
		var flat := []
		for row in normalized_cells_type:
			for t in row:
				flat.append(t)
		return flat


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
	var normalized = cells.duplicate()
	for i in range(rotation_state):
		normalized = rotate_90_clockwise(normalized)
	return [
		normalized.slice(0, 3),
		normalized.slice(3, 6),
		normalized.slice(6, 9)
	]

func turn(direction: Globals.TurnDirection) -> void:
	body.rotation_degrees = rotation_state * 90
	var turn_step = +1 if direction == Globals.TurnDirection.CLOCKWISE else -1
	rotation_state = (rotation_state + turn_step + 4) % 4
	
	var target_rotation = body.rotation_degrees + turn_step * 90
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(body, "rotation_degrees", target_rotation, TURN_ANIMATION_DURATION).set_trans(Tween.TRANS_QUAD)
	
	turn_sound.play(0.2)
	await get_tree().create_timer(1.5).timeout
	turn_sound.stop()

func rotate_90_clockwise(arr: Array) -> Array:
	return [
		arr[6], arr[3], arr[0],
		arr[7], arr[4], arr[1],
		arr[8], arr[5], arr[2]
	]

# Deprecated: use `normalize_cells()` instead, which includes animation
func _normalize_cells_non_rotate() -> Array:
	return [
		cells.slice(0, 3),
		cells.slice(3, 6),
		cells.slice(6, 9)
	]

# Deprecated: use `turn()` instead, which includes animation
func _turn_snappy(direction: Globals.TurnDirection) -> void:
	var normalized_cells = normalize_cells()
	var turned_cells = _turn_array(normalized_cells, direction)
	var turned_types: Array[Globals.CellType] = []
	for i in range(3):
			for j in range(3):
				turned_types.append(turned_cells[i][j].type)
	
	for i in cells.size():
		cells[i].type = turned_types[i]

# Deprecated
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
