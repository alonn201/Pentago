extends Control

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var adress: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Address


const PORT = 1771
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_pressed() -> void:
	
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	upnp_setup()

func _on_join_pressed() -> void:
	
	main_menu.hide()
	enet_peer.create_client("127.0.0.1",PORT)
	multiplayer.multiplayer_peer = enet_peer

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
		print("Success! Join address: %s:%d" % [external_ip, PORT])
