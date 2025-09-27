extends Control

@onready var main_menu: PanelContainer = $MainMenu
@onready var address_entry: LineEdit = $MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var address_copy: Label = $MainMenu/MarginContainer/VBoxContainer/HBoxContainer/AddressCopy
@onready var error_msg: Label = $MainMenu/MarginContainer/VBoxContainer/ErrorMsg

const PORT = 1771
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed() -> void:
	var result := enet_peer.create_server(PORT)
	if result != OK:
		error_msg.text = "Failed to host"
		await get_tree().create_timer(1.0).timeout
		error_msg.text = ""
	
	multiplayer.multiplayer_peer = enet_peer
	
	upnp_setup()
	
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_join_button_pressed() -> void:
	var result := enet_peer.create_client(address_entry.text, PORT)
	if result != OK:
		error_msg.text = "Failed to connect"
		await get_tree().create_timer(1.0).timeout
		error_msg.text = ""
	
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	var external_ip := upnp.query_external_address()
	if external_ip == "" or external_ip == null:
		print("UPnP mapped port but external IP could not be determined.")
	else:
		address_copy.text = str(external_ip)

func _on_copy_address_pressed() -> void:
	var ip = address_copy.text
	if address_copy and address_copy.text != "":
		DisplayServer.clipboard_set(address_copy.text)
		address_copy.text = "Copied to clipboard"
		await get_tree().create_timer(1.0).timeout
		address_copy.text = str(ip)

func _on_peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)
	main_menu.hide()
