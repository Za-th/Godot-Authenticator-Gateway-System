extends Node

var network = ENetMultiplayerPeer.new()
const _IP = "localhost"
const _PORT = 1911


func _ready():
	ConnectToServer()


func ConnectToServer():
	network.create_client(_IP, _PORT)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)


func _OnConnectionFailed():
	print("Failed to connect to authentification server")
	multiplayer.connection_failed.disconnect(_OnConnectionFailed)
	multiplayer.connected_to_server.disconnect(_OnConnectionSucceeded)
	get_tree().create_timer(2).timeout.connect(ConnectToServer)

func _OnConnectionSucceeded():
	print("Succesfully connected to authentification server")


# auth login functions

@rpc("authority", "call_remote")
func AuthenticatePlayer(username:String, password:String, player_id:int):
	print("sending out authentification request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)


@rpc("authority", "call_remote")
func AuthentificationResults(result:bool, player_id:int, token:String):
	print("results received")
	Gateway.ReturnLoginRequest(result, player_id, token)


# auth signup functions

@rpc("authority", "call_remote")
func CreateAccount(username:String, password:String, player_id:int):
	print("Sending out create acct request")
	rpc_id(1, "CreateAccount", username, password, player_id)

@rpc("authority", "call_remote")
func CreateAccountResults(result:bool, player_id:int, message:int):
	print("Results returned")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
