extends Node

const SESSION_FILE := "usr://.gsprite"

var Main : Node
var Canvas : Node
var Colors : Node
var Tool : Node

var colors := [Color.black, Color.white]
var show_grid := false
var session := {
	"save_dir": "",
	"open_dir": "",
	"palette": "",
}
var session_has_changed := false

var clipboard_image : Image

func session_load() -> void:
	var file := File.new()
	if file.open(SESSION_FILE, File.READ) == OK:
		var json := file.get_as_text()
		var error := validate_json(json)
		if error == "":
			session = parse_json(json)
			if session.get("maximized"):
				OS.window_maximized = true
		else:
			print("Failed to parse session JSON: " + error)
		file.close()

func session_save() -> void:
	if not session_has_changed:
		return
	
	session.maximized = OS.window_maximized
	
	var file := File.new()
	if file.open(SESSION_FILE, File.WRITE) == 0:
		file.store_string(to_json(session))
		file.close()

func session_set(key: String, value: String) -> void:
	session_has_changed = true
	session[key] = value
