extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
const PORT = 1910
const MAX_PLAYERS = 100


func _ready():
	StartServer()


func _process(_delta):
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()


func StartServer():
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	network.peer_connected.connect(_Peer_Connected)
	network.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")


# login functions

@rpc("any_peer", "call_remote")
func LoginRequest(username:String, password:String):
	print("login request received")
	var player_id = multiplayer.get_remote_sender_id()
	Authenticate.AuthenticatePlayer(username.to_lower(), password, player_id)

@rpc("authority", "call_remote")
func ReturnLoginRequest(result:bool, player_id:int, token:String):
	print("replying to player " + str(player_id) +  " login")
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	await get_tree().create_timer(2).timeout
	network.disconnect_peer(player_id)


# sign up functions

@rpc("any_peer", "call_remote")
func RequestSignUp(username:String, password:String):
	print("Requested sign up")
	var player_id:int = multiplayer.get_remote_sender_id()
	var valid_request:bool = true
	
	if username == "":
		valid_request = false
	if password == "":
		valid_request = false
	if password.length() <= 6:
		valid_request = false
	
	if valid_request == false:
		ReturnCreateAccountRequest(valid_request, player_id, 1)
	else:
		Authenticate.CreateAccount(username.to_lower(), password, player_id)

@rpc("authority", "call_remote")
func ReturnCreateAccountRequest(valid_request:bool, player_id:int, message:int):
	print("Sending new account results to player")
	# message: 1 is failed, 2 is existing username, 3 is successful
	rpc_id(player_id, "ReturnCreateAccountRequest", valid_request, message)
	# need to wait for rpc to call b4 disconnecting player
	await get_tree().create_timer(3).timeout
	network.disconnect_peer(player_id)
