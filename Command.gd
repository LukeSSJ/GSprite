extends Node

func new() -> void:
	Global.Main.new()

func save() -> void:
	Global.Main.save()

func save_as() -> void:
	Global.Main.save_as()

func open() -> void:
	Global.Main.open()

func undo() -> void:
	Global.Canvas.undo()

func redo() -> void:
	Global.Canvas.redo()

func select_all() -> void:
	Global.Canvas.select_all()

func deselect() -> void:
	Global.Canvas.deselect()

func cut() -> void:
	pass

func copy() -> void:
	pass

func paste() -> void:
	print(OS.clipboard)

func delete() -> void:
	Global.Canvas.delete()

func confirm() -> void:
	Global.Canvas.confirm()

func rotate_clockwise() -> void:
	Global.Canvas.rotate_clockwise()

func rotate_anticlockwise() -> void:
	Global.Canvas.rotate_anticlockwise()

func flip_horizontal() -> void:
	Global.Canvas.flip_horizontal()

func flip_vertical() -> void:
	Global.Canvas.flip_vertical()

func resize_canvas() -> void:
	Global.Main.resize_canvas()

func tool_set(new_tool : String):
	Global.Main.tool_set(new_tool)

func palete_select(number : int, color_index:=0):
	Global.Colors.palete_select(number, color_index)

func zoom_in() -> void:
	Global.Canvas.zoom_in()

func zoom_out() -> void:
	Global.Canvas.zoom_out()

func zoom_reset() -> void:
	Global.Canvas.zoom_reset()
