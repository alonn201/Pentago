extends Control

@onready var address_copy: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AddressCopy
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var h_box_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer

var waiting = true
var ip = ""

func _ready() -> void:
	Network.upnp_done.connect(_on_upnp_done)
	Network.upnp_failed.connect(_on_upnp_failed)
	Network.connected.connect(_on_network_connected)
	Network.start_game.connect(_on_start_game)
	
	var counter := 0
	while(waiting):
		label.text = "Waiting for player" + ".".repeat(counter % 4)
		counter += 1
		await get_tree().create_timer(1.0).timeout

func _on_upnp_failed(reason: String) -> void:
	label.text = "UPnP: " + reason
	h_box_container.hide()

func _on_upnp_done(external_ip: String) -> void:
	address_copy.text = str(external_ip)
	ip = external_ip 

func _on_copy_address_pressed() -> void:
	DisplayServer.clipboard_set(address_copy.text)
	address_copy.text = "Copied to clipboard"
	await get_tree().create_timer(1.0).timeout
	address_copy.text = str(ip)

func _on_network_connected(id: int) -> void:
	print("Network: connected id=", id)
	waiting = false
	if multiplayer.is_server():
		await get_tree().create_timer(0.25).timeout
		Network.rpc_change_scene_to_game()

func _on_start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/pentago.tscn")

func _on_back_button_pressed() -> void:
	Network.close()
	get_tree().change_scene_to_file("res://Scenes/control.tscn")
