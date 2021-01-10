extends Node2D

signal update_size
signal update_cursor

const MAX_UNDOS = 10

var image_file
var image_name
var image
var image_size
var image_preview
var zoom_level = 10.0
var zoom
var undoStack = []
var undoIndex = -1

onready var Output = $Output
onready var Preview = $Preview

func _ready():
	#OS.window_maximized = true
	image = Image.new()
	image_preview = Image.new()
	
	image_size = Vector2(32, 32)
	
	image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image_preview.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	
	position = OS.get_window_size() / 2
	undo_add()
	update_output()
	update_preview()
	emit_signal("update_size", image_size)

func mouse_event(event):
	var mouse_pos = get_global_mouse_position() - position + image_size / 2
	mouse_pos.x = floor(mouse_pos.x)
	mouse_pos.y = floor(mouse_pos.y)
	emit_signal("update_cursor", mouse_pos)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				Global.Tool.click(mouse_pos, 0)
			else:
				Global.Tool.release(mouse_pos)
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				Global.Tool.click(mouse_pos, 1)
			else:
				Global.Tool.release(mouse_pos)
		elif event.button_index == BUTTON_WHEEL_UP:
			Command.zoom_in()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			Command.zoom_out()
	else:
		Global.Tool.move(mouse_pos)

func load_image(filename):
	image.load(filename)
	image_size = image.get_size()
	update_output()
	emit_signal("update_size", image_size)

func zoom_update():
	zoom_level += 1
	zoom = 1 / zoom_level
	$Camera.zoom = Vector2(zoom, zoom)

func undo_add():
	undoStack.resize(undoIndex + 1)
	undoStack.append(image.duplicate())
	if len(undoStack) > MAX_UNDOS:
		undoStack.pop_front()
	else:
		undoIndex += 1

func undo():
	if undoIndex > 0:
		undoIndex -= 1
		image = undoStack[undoIndex].duplicate()
		Global.Tool.image = image
		update_output()
	else:
		print("Nothing to undo")

func redo():
	if undoIndex < len(undoStack) - 1:
		undoIndex += 1
		image = undoStack[undoIndex].duplicate()
		Global.Tool.image = image
		update_output()
	else:
		print("Nothing to redo")

func update_output():
	var tex = ImageTexture.new()
	tex.create(image_size.x, image_size.y, Image.FORMAT_RGBA8, 0)
	tex.set_data(image)
	Output.set_texture(tex)

func update_preview():
	var tex = ImageTexture.new()
	tex.create(image_size.x, image_size.y, Image.FORMAT_RGBA8, 0)
	tex.set_data(image_preview)
	Preview.set_texture(tex)
