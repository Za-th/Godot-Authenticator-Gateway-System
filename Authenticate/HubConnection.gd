extends Node

var network:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var gateway_api:SceneMultiplayer = SceneMultiplayer.new()
const PORT:int = 1912
const MAX_SERVERS:int = 1

# gameservername:String: peerid:int
var gameserverlist:Dictionary = {}


func _ready() -> void:
	StartServer()


func _process(_delta) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()


func StartServer() -> void:
	network.create_server(PORT, MAX_SERVERS)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	print("Hub Connection Started")
	
	network.peer_connected.connect(_Peer_Connected)
	network.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(game_server_id:int) -> void:
	print("Game Server " + str(game_server_id) + " Connected")
	# if adding multiple game servers need to assign diff names
	gameserverlist["Main"] = game_server_id


func _Peer_Disconnected(game_server_id:int) -> void:
	print("Game Server " + str(game_server_id) + " Disconnected")
	# remove game server from list
	for name in gameserverlist:
		if gameserverlist[name] == game_server_id:
			gameserverlist.erase(name)


func DistributeLoginToken(username:String, token:String, gameserver:String) -> void:
	if gameserverlist.has(gameserver):
		var gameserver_peer_id:int = gameserverlist[gameserver]
		print("Sent token to gameserver: " + gameserver)
		rpc_id(gameserver_peer_id, "ReceiveLoginToken", username, token)
	else:
		print(gameserver + " has not been connected")

@rpc("authority", "call_remote")
func ReceiveLoginToken():
	pass
