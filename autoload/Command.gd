extends Node

onready var Change = preload("res://canvas/Change.gd")

func new() -> void:
	Global.Main.image_new()

func save() -> void:
	Global.Main.image_save()

func save_as() -> void:
	Global.Main.image_save_as()

func open() -> void:
	Global.Main.image_open()

func undo() -> void:
	Global.Canvas.undo()

func redo() -> void:
	Global.Canvas.redo()

func select_all() -> void:
	Global.Canvas.select_all()

func deselect() -> void:
	Global.Canvas.deselect()

func delete() -> void:
	Global.Canvas.delete()

func cut() -> void:
	Global.Canvas.cut()

func copy() -> void:
	Global.Canvas.copy()

func paste() -> void:
	Global.Canvas.paste()

func import() -> void:
	Global.Main.import_image()

func rotate_clockwise() -> void:
	var change = Change.new()
	change.action = "rotate_clockwise"
	change.undo_action = "rotate_anticlockwise"
	Global.Canvas.make_change(change)

func rotate_anticlockwise() -> void:
	var change = Change.new()
	change.action = "rotate_anticlockwise"
	change.undo_action = "rotate_clockwise"
	Global.Canvas.make_change(change)

func flip_horizontal() -> void:
	var change = Change.new()
	change.action = "flip_horizontal"
	change.undo_action = "flip_horizontal"
	Global.Canvas.make_change(change)

func flip_vertical() -> void:
	var change = Change.new()
	change.action = "flip_vertical"
	change.undo_action = "flip_vertical"
	Global.Canvas.make_change(change)

func resize_canvas() -> void:
	Global.Main.resize_canvas()

func toggle_grid() -> void:
	Global.show_grid = !Global.show_grid
	Global.Canvas.toggle_grid(Global.show_grid)

# Key only

func select_palete() -> void:
	Global.Main.select_palete()

func confirm() -> void:
	Global.Canvas.confirm()

func cancel() -> void:
	Global.Canvas.cancel()

func tool_set(new_tool : String) -> void:
	Global.Main.tool_set(new_tool)

func palete_select(palete_number: String, color_index:="0"):
	Global.Colors.palete_select_color(int(palete_number), int(color_index))

func zoom_in() -> void:
	Global.Canvas.zoom_in()

func zoom_out() -> void:
	Global.Canvas.zoom_out()

func zoom_reset() -> void:
	Global.Canvas.zoom_reset()

func shift_left() -> void:
	Global.Canvas.shift_selection(Vector2(-1, 0))

func shift_right() -> void:
	Global.Canvas.shift_selection(Vector2(1, 0))

func shift_up() -> void:
	Global.Canvas.shift_selection(Vector2(0, -1))

func shift_down() -> void:
	Global.Canvas.shift_selection(Vector2(0, 1))
