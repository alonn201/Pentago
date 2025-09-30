extends Node

signal connected(peer_id : int)
signal connection_failed(reason : String)
signal upnp_done(external_ip : String)
signal upnp_failed(reason : String)
signal start_game()

const PORT := 1771
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var upnp_thread: Thread

func start_server(port: int = PORT) -> bool:
	var res := enet_peer.create_server(port)
	if res != OK:
		emit_signal("connection_failed", "create_server failed: %s" % res)
		return false

	get_tree().set_multiplayer(SceneMultiplayer.new())
	# Use the stable getter to access the MultiplayerAPI
	var mpapi := get_tree().get_multiplayer()
	mpapi.multiplayer_peer = enet_peer
	# Connect to peer_connected once
	mpapi.peer_connected.connect(_on_peer_connected)

	upnp_thread = Thread.new()
	upnp_thread.start(Callable(self, "_threaded_upnp_setup"))
	
	return true

func start_client(host: String, port: int = PORT) -> bool:
	var res := enet_peer.create_client(host, port)
	if res != OK:
		emit_signal("connection_failed", "create_client failed: %s" % res)
		return false

	# Same setup for client
	get_tree().set_multiplayer(SceneMultiplayer.new())
	var mpapi := get_tree().get_multiplayer()
	mpapi.multiplayer_peer = enet_peer
	mpapi.peer_connected.connect(_on_peer_connected)

	return true

func _on_peer_connected(id: int) -> void:
	emit_signal("connected", id)


func _threaded_upnp_setup() -> void:
	upnp_setup()

# returns external IP string, or null if failure (also emits upnp_failed on error)
func upnp_setup(port: int = PORT) -> void:
	var upnp := UPNP.new()

	var discover_result := upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		emit_signal("upnp_failed", "UPnP discover failed: %s" % discover_result)

	var gateway := upnp.get_gateway()
	if not gateway or not gateway.is_valid_gateway():
		emit_signal("upnp_failed", "Invalid UPnP gateway")

	var map_result := upnp.add_port_mapping(port)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		emit_signal("upnp_failed", "Add port mapping failed: %s" % map_result)

	var external_ip := upnp.query_external_address()
	if external_ip == "" or external_ip == null:
		if gateway.has_method("query_external_ip"):
			external_ip = gateway.query_external_ip()
			
	call_deferred("emit_signal", "upnp_done", external_ip)

func request_start_game() -> void:
	if not multiplayer.is_server():
		return                                # safety: only host decides
	rpc_change_scene_to_game()

@rpc("any_peer", "call_local", "reliable")
func rpc_change_scene_to_game() -> void:
	start_game.emit()
