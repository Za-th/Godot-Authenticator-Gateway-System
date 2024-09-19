extends Node3D

# TODO backup player data

@onready var json:JSON = JSON.new()
var PlayerIDs

func _ready():
	var PlayerIDs_file = FileAccess.open("res://PlayerIDs.json", FileAccess.READ)
	var error:Error = json.parse(PlayerIDs_file.get_as_text())
	
	if error == OK:
		PlayerIDs = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
	
	PlayerIDs_file.close()

func SavePlayerIDs():
	var save_file = FileAccess.open("res://PlayerIDs.json", FileAccess.WRITE)
	save_file.store_string(str(PlayerIDs))
	save_file.close()
