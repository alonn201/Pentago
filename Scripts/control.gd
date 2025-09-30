extends Control

@onready var main_menu: PanelContainer = $MainMenu
@onready var address_entry: LineEdit = $MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var error_msg: Label = $MainMenu/MarginContainer/VBoxContainer/ErrorMsg

func _ready() -> void:
	Network.connected.connect(_on_network_connected)
	Network.connection_failed.connect(_on_connection_failed)

func _on_host_button_pressed() -> void:
	var ok := Network.start_server()
	if not ok:
		error_msg.text = "Failed to host"
		await get_tree().create_timer(1.0).timeout
		error_msg.text = ""
	
	get_tree().change_scene_to_file("res://Scenes/waiting_screen.tscn")

func _on_join_button_pressed() -> void:
	var host := address_entry.text.strip_edges()
	var ok := Network.start_client(host)
	if not ok:
		error_msg.text = "Failed to connect"
		await get_tree().create_timer(1.0).timeout
		error_msg.text = ""

func _on_network_connected(id: int) -> void:
	print("Network: connected id=", id)
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://Scenes/pentago.tscn")

func _on_connection_failed(reason) -> void:
	error_msg.text = str(reason)
	await get_tree().create_timer(1.5).timeout
	error_msg.text = ""
