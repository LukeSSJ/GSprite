extends Node2D

onready var CanvasList := $CanvasList
onready var UI := $UI
onready var Colors := $UI/Colors
onready var Tools := $UI/Tools
onready var ImageTabs = $UI/TopBar/TabWrap/ImageTabs
onready var Backdrop := $UI/Backdrop
onready var Dialog := $UI/Backdrop/Dialog
onready var UnsavedChanges := $UI/Backdrop/Dialog/UnsavedChanges
onready var UnsavedTab := $UI/Backdrop/Dialog/UnsavedTab
onready var NewImage := $UI/Backdrop/Dialog/NewImage
onready var SaveImage := $UI/Backdrop/Dialog/SaveImage
onready var OpenImage := $UI/Backdrop/Dialog/OpenImage
onready var ImportImage := $UI/Backdrop/Dialog/ImportImage
onready var ResizeCanvas := $UI/Backdrop/Dialog/ResizeCanvas
onready var SelectPalette := $UI/Backdrop/Dialog/SelectPalette

onready var Canvas = preload("res://canvas/Canvas.tscn")
onready var Change = preload("res://canvas/Change.gd")

var new_count := 1

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	ImageTabs.connect("tab_changed", self, "tab_changed")
	ImageTabs.connect("tab_close", self, "tab_close")
	ImageTabs.connect("reposition_active_tab_request", self, "tab_move")
	
	for popup in Dialog.get_children():
		if popup is Popup:
			popup.connect("about_to_show", Backdrop, "show")
			popup.connect("popup_hide", Backdrop, "hide")
	
	UnsavedChanges.connect("confirmed", self, "quit")
	UnsavedTab.connect("confirmed", self, "tab_close_confirmed")
	NewImage.connect("new_image", self, "image_new_confirmed")
	SaveImage.connect("file_selected", self, "image_save_confirmed")
	OpenImage.connect("file_selected", self, "image_open_confirmed")
	ImportImage.connect("file_selected", self, "import_image_confirmed")
	ResizeCanvas.connect("resize_canvas", self, "resize_canvas_confirmed")
	SelectPalette.connect("palette_selected", self, "palette_selected")
	
	Global.Main = self
	Global.Colors = Colors
	
	Global.session_load()
	Shortcut.load_shortcuts()
	SelectPalette.load_palettes()
	
	for button in Tools.get_children():
		button.text = button.name
		button.connect("pressed", Command, "tool_set", [button.name])
	tool_set("Pencil")
	
	image_new_confirmed(Vector2(32, 32))
	Global.Canvas.blank = true
	
	# Open files from cmd args
	for arg in OS.get_cmdline_args():
		image_open_confirmed(arg)


func _unhandled_input(event) -> void:
	if event is InputEventMouse:
		Global.Canvas.mouse_event(event)
	
	# Keyboard shortcuts
	if event is InputEventKey and event.pressed:
		var key_input = OS.get_scancode_string(event.get_scancode_with_modifiers())
		var command = Shortcut.command.get(key_input)
		if command:
			var args : PoolStringArray = command.split(":")
			command = args[0]
			args.remove(0)
			if Command.has_method(command):
				print("Command: " + command + " " + args.join(" "))
				Command.callv(command, args)
			else:
				print("Error unkown command: " + command)


func _notification(message) -> void:
	if message == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if UnsavedChanges.visible:
			return
		var dirty := false
		for canvas in CanvasList.get_children():
			if canvas.dirty:
				dirty = true
				break
		if dirty:
			Backdrop.show()
			UnsavedChanges.popup_centered(Vector2(200, 100))
		else:
			quit()


func quit():
	Global.session_save()
	get_tree().quit()


func tool_set(tool_name) -> void:
	var new_tool := Tools.get_node_or_null(tool_name)
	if not new_tool:
		printerr("Error unknown tool: " + str(tool_name))
	
	Global.Tool = new_tool
	UI.update_tool(tool_name)


func tab_changed(tab : int) -> void:
	Global.Canvas.hide()
	Global.Canvas = CanvasList.get_child(tab)
	Global.Canvas.make_active()


func tab_close(tab: int) -> void:
	if CanvasList.get_child_count() == 1:
		return
	
	ImageTabs.current_tab = tab
	if Global.Canvas.dirty:
		UnsavedTab.popup_centered(Vector2(200, 100))
		return
	
	tab_close_confirmed()


func tab_close_current() -> void:
	tab_close(ImageTabs.current_tab)



func tab_close_confirmed() -> void:
	var tab : int = ImageTabs.current_tab
	ImageTabs.remove_tab(tab)
	CanvasList.get_child(tab).queue_free()
	Global.Canvas = CanvasList.get_child(ImageTabs.current_tab)
	if Global.Canvas.is_queued_for_deletion():
		Global.Canvas = CanvasList.get_child(ImageTabs.current_tab + 1)
	Global.Canvas.show()
	Global.Canvas.make_active()


func tab_move(new_index: int):
	var canvas := CanvasList.get_child(ImageTabs.current_tab)
	CanvasList.move_child(canvas, new_index)


func tab_rename(new_name):
	ImageTabs.set_tab_title(ImageTabs.current_tab, new_name)


func image_new() -> void:
	NewImage.popup_centered(Vector2(200, 100))
	NewImage.on_popup()


func image_new_confirmed(size:=Vector2.ZERO) -> void:
	var canvas = Canvas.instance()
	var tab := CanvasList.get_child_count()
	if size != Vector2.ZERO:
		canvas.image_size = size
	
	CanvasList.add_child(canvas)
	canvas.image_name = "new" + str(new_count)
	
	new_count += 1
	if Global.Canvas:
		Global.Canvas.hide()
	canvas.connect("update_title", self, "tab_rename")
	canvas.connect("update_zoom", UI, "update_zoom")
	canvas.connect("update_size", UI, "update_size")
	canvas.connect("update_cursor", UI, "update_cursor")
	ImageTabs.add_tab(canvas.image_name)
	ImageTabs.current_tab = tab
	Global.Canvas = canvas
	Global.Canvas.make_active()


func image_save() -> void:
	if Global.Canvas.image_file:
		image_save_confirmed(Global.Canvas.image_file)
	else:
		image_save_as()


func image_save_as() -> void:
	if Global.session.get("save_dir"):
		SaveImage.current_dir = Global.session.save_dir
		if Global.Canvas.image_name.ends_with(".png"):
			SaveImage.current_file = Global.Canvas.image_name
		else:
			SaveImage.current_file = ""
	Backdrop.show()
	SaveImage.popup_centered()


func image_save_confirmed(file: String) -> void:
	print("Saved image to: " + file)
	Global.session_set("save_dir", file.get_base_dir())
	Global.Canvas.image_save(file)
	OS.set_window_title("GSprite - " + Global.Canvas.title)


func image_open() -> void:
	Backdrop.show()
	OpenImage.popup_centered()
	if Global.session.get("open_dir"):
		OpenImage.current_dir = Global.session.open_dir


func image_open_confirmed(file : String) -> void:
	print("Opened file: " + file)
	Global.session_set("open_dir", file.get_base_dir())
	
	if not Global.Canvas.blank:
		image_new_confirmed()
		new_count -= 1
		Global.Canvas.blank = false
		
	if Global.Canvas.image_load(file):
		OS.set_window_title(Global.Canvas.image_name)


func import_image() -> void:
	Backdrop.show()
	ImportImage.popup_centered()
	
	if Global.session.get("open_dir"):
		ImportImage.current_dir = Global.session.open_dir


func import_image_confirmed(file : String) -> void:
	print("Importing file " + file)
	Global.session_set("open_dir", file.get_base_dir())
	Global.Canvas.import_image(file)


func resize_canvas() -> void:
	Backdrop.show()
	ResizeCanvas.popup_centered(Vector2(200, 100))
	ResizeCanvas.on_popup()


func resize_canvas_confirmed(size: Vector2, image_position: Vector2) -> void:
	var change = Change.new()
	change.action = "resize_canvas"
	change.params = [size, image_position]
	change.undo_action = "load_image"
	change.undo_params = [Global.Canvas.image.duplicate()]
	Global.Canvas.make_change(change)


func select_palette() -> void:
	SelectPalette.popup_centered()


func palette_selected(palette) -> void:
	Global.session_set("palette", palette.file)
	Colors.palette_set(palette)
