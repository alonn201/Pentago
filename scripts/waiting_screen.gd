extends Control

@onready var address_copy: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AddressCopy
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label

var waiting = true

func _ready() -> void:
	Network.upnp_done.connect(_on_upnp_done)
	Network.connected.connect(_on_network_connected)
	
	while(waiting):
		label.text = "Waiting for player"
		for i in range(4):
			await get_tree().create_timer(1.0).timeout
			label.text += "."

func _on_upnp_done(external_ip: String) -> void:
	address_copy.text = str(external_ip)

func _on_copy_address_pressed() -> void:
	var ip = address_copy.text
	if address_copy and address_copy.text != "":
		DisplayServer.clipboard_set(address_copy.text)
		address_copy.text = "Copied to clipboard"
		await get_tree().create_timer(1.0).timeout
		address_copy.text = str(ip)

func _on_network_connected(id: int) -> void:
	print("Network: connected id=", id)
	waiting = false
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scenes/pentago.tscn")
