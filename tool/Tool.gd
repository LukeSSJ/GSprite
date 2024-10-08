extends Node

var tool_name: String
var drawing: bool
var drawing_button: int
var start_pos: Vector2
var prev_pos: Vector2
var use_preview: bool
var button_index: int
var draw_color: Color
var change_made: bool
var control_pressed: bool
var dirty: bool
var dirty_rect: Rect2

func click(pos: Vector2, button: int, control: bool) -> void:
	if drawing:
		return
	
	drawing = true
	use_preview = false
	change_made = false
	dirty = false
	start_pos = pos
	prev_pos = pos
	
	button_index = button
	control_pressed = control
	
	draw_color = Global.colors[button_index]
	
	if Global.canvas.select.visible:
		Global.canvas.select.confirm_selection()
		
	start(pos)
	draw(pos)


func release(pos: Vector2, button: int) -> void:
	if not drawing or button != button_index:
		return
	
	end(pos)
	stop_drawing()


func move(pos: Vector2) -> void:
	if drawing:
		draw(pos)
		prev_pos = pos


func stop_drawing() -> void:
	if not drawing:
		return
	
	drawing = false
	
	Global.canvas.image_preview.fill(Color.TRANSPARENT)
	Global.canvas.update_preview()
	
	if change_made:
		var new_image: Image
		var prev_image: Image
		var change_pos: Vector2
		
		if dirty:
			change_pos = dirty_rect.position
			dirty_rect.size += Vector2(1, 1)
			new_image = Global.canvas.image.get_region(dirty_rect)
			prev_image = Global.canvas.prev_image.get_region(dirty_rect)
		else:
			change_pos = Vector2.ZERO
			new_image = Global.canvas.image.duplicate()
			prev_image = Global.canvas.prev_image.duplicate()
		
		var Change = preload("res://canvas/Change.gd")
		var change = Change.new()
		change.action = "blit_image"
		change.params = [new_image, change_pos]
		change.undo_action = "blit_image"
		change.undo_params = [prev_image, change_pos]
		Global.canvas.make_change(change)


# Drawing functions

func image_draw_start() -> void:
	if use_preview:
		Global.canvas.image_preview.fill(Color.TRANSPARENT)


func image_draw_end() -> void:
	if use_preview:
		Global.canvas.update_preview()
	else:
		Global.canvas.update_output()


func cancel() -> void:
	stop_drawing()


func image_draw_point(pos: Vector2) -> void:
	if not Global.canvas.image_rect.has_point(pos):
		return
	
	if use_preview:
		Global.canvas.image_preview.set_pixelv(pos, draw_color)
		Global.canvas.image_preview.set_pixelv(pos, draw_color)
	else:
		var new_color := draw_color
		new_color.blend(Global.canvas.image.get_pixelv(pos))
		Global.canvas.image.set_pixelv(pos, new_color)
		change_made = true
	
	if dirty:
		dirty_rect = dirty_rect.expand(pos)
	else:
		dirty_rect = Rect2(pos, Vector2(1, 1))
		dirty = true


func image_draw_line(pos1: Vector2, pos2: Vector2) -> void:
	var dx = abs(pos2.x - pos1.x)
	var dy = abs(pos2.y - pos1.y)
	var sx := 1 if pos1.x < pos2.x else -1
	var sy := 1 if pos1.y < pos2.y else -1
	var step = dx - dy
	
	while true:
		image_draw_point(pos1)
		if pos1 == pos2:
			break
		var a = 2 * step
		if a > -dy:
			step -= dy
			pos1.x += sx
		if a < dx:
			step += dx
			pos1.y += sy


func image_draw_rect(pos1: Vector2, pos2: Vector2) -> void:
	image_draw_point(pos1)
	
	var step = sign(pos2.x - pos1.x)
	var i = pos1.x
	
	while i != pos2.x:
		i += step
		image_draw_point(Vector2(i, pos1.y))
		image_draw_point(Vector2(i, pos2.y))
	
	step = sign(pos2.y - pos1.y)
	i = pos1.y
	
	while i != pos2.y:
		i += step
		image_draw_point(Vector2(pos1.x, i))
		image_draw_point(Vector2(pos2.x, i))


func image_draw_ellipse(pos1: Vector2, pos2: Vector2) -> void:
	if pos1 == pos2:
		image_draw_point(pos1)
		return
	
	var top_left := Vector2(min(pos1.x, pos2.x), min(pos1.y, pos2.y))
	var bottom_right := Vector2(max(pos1.x, pos2.x), max(pos1.y, pos2.y))
	var center = ((top_left + bottom_right) / 2).round()
	var even = Vector2(int(top_left.x + bottom_right.x) % 2, int(top_left.y + bottom_right.y) % 2)
	var r = bottom_right - center
	
	if r.x == 0:
		r.x = 1
	if r.y == 0:
		r.y = 1
	
	var x := int(top_left.x)
	var y
	while x <= center.x:
		var angle := acos((x - center.x) / r.x)
		y = round(r.y * sin(angle) + center.y)
		if not is_nan(y):
			image_draw_point(Vector2(x - even.x, y))
			image_draw_point(Vector2(x - even.x, 2 * center.y - y - even.y))
			image_draw_point(Vector2(2 * center.x - x, y))
			image_draw_point(Vector2(2 * center.x - x, 2 * center.y - y - even.y))
		x += 1
	
	y = int(top_left.y)
	while y <= center.y:
		var angle := asin((y - center.y) / r.y)
		x = round(r.x * cos(angle) + center.x)
		image_draw_point(Vector2(x, y - even.y))
		image_draw_point(Vector2(2 * center.x - x - even.x, y - even.y))
		image_draw_point(Vector2(x, 2 * center.y - y))
		image_draw_point(Vector2(2 * center.x - x - even.x, 2 * center.y - y))
		y += 1


func image_fill(pos: Vector2, color_replace: Color) -> void:
	if not Global.canvas.image_rect.has_point(pos):
		return
	
	if ImageTools.image_flood_fill(Global.canvas.image, pos, color_replace):
		change_made = true


func image_fill_global(pos: Vector2, color_replace: Color) -> void:
	if not Global.canvas.image_rect.has_point(pos):
		return
	
	change_made = true
	var color_find : Color = Global.canvas.image.get_pixelv(pos)
	
	for x in Global.canvas.image_size.x:
		for y in Global.canvas.image_size.y:
			if ImageTools.colors_match(Global.canvas.image.get_pixel(x, y), color_find):
				Global.canvas.image.set_pixel(x, y, color_replace)


func image_grab_color(pos : Vector2) -> void:
	if Global.canvas.image_rect.has_point(pos):
		Global.color_section.color_set(Global.canvas.image.get_pixelv(pos), button_index)


# Methods for overriding

func start(_pos : Vector2) -> void:
	pass


func draw(_pos : Vector2) -> void:
	pass


func end(_pos : Vector2) -> void:
	pass
