extends Node

var network = ENetMultiplayerPeer.new()
const PORT = 1911
const MAX_SERVERS = 5

func _ready():
	StartServer()
	randomize()


func StartServer():
	network.create_server(PORT, MAX_SERVERS)
	multiplayer.multiplayer_peer = network
	
	network.peer_connected.connect(_Peer_Connected)
	network.peer_disconnected.connect(_Peer_Disconnected)
	print("Authenticate Server Started")


func _Peer_Connected(gateway_id:int) -> void:
	print("Gateway " + str(gateway_id) + " Connected")


func _Peer_Disconnected(gateway_id:int) -> void:
	print("Gateway " + str(gateway_id) + " Disconnected")


# login/token functions

@rpc("any_peer", "call_remote")
func AuthenticatePlayer(username, password, player_id):
	print("authentification request received")
	var token:String = ""
	var gateway_id:int = multiplayer.get_remote_sender_id()
	var result:bool
	var hashed_password:String = ""
	if not PlayerData.PlayerIDs.has(username):
		print("User not recognised")
		result = false
	else:
		var retreived_salt:String = PlayerData.PlayerIDs[username].Salt
		hashed_password = GenerateHashedPassword(password, retreived_salt)
	if not PlayerData.PlayerIDs[username].Password == hashed_password:
		result = false
	else:
		print("Succesful authentification")
		result = true
		
		# create token
		var random_num:int = randi()
		var hashed:String = str(random_num).sha256_text()
		
		var timestamp:String = str(Time.get_unix_time_from_system())
		token = hashed + " " + timestamp
		
		# send token to game server
		# TODO if multiple game servers then need to distribute load and change name
		var gameserver:String = "Main"
		# username must be lower as stored player usernames are lower
		HubConnection.DistributeLoginToken(username.to_lower(), token, gameserver)
		
	print("authentification result sent to gateway server " + str(gateway_id))
	# send result and token to player
	rpc_id(gateway_id, "AuthentificationResults", result, player_id, token)

@rpc("any_peer")
func AuthentificationResults(_result, _player_id):
	pass


# sign up functions

@rpc("any_peer", "call_remote")
func CreateAccount(username:String, password:String, player_id:int):
	var gateway_id:int = multiplayer.get_remote_sender_id()
	var result:bool
	var message:int
	
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt:String = GenerateSalt()
		var hashed_password:String = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt}
		PlayerData.SavePlayerIDs()
	
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func GenerateHashedPassword(password:String, salt:String):
	# hash password multiple times so hashing is slow against brute force attacks
	var hashed_password:String = password
	var rounds = pow(2, 18)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password

@rpc("authority", "call_remote")
func CreateAccountResults():
	pass
