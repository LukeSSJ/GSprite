extends "res://tool/Tool.gd"

func start(pos: Vector2):
	image_draw_start()
	image_fill(pos, draw_color)
	image_draw_end()
