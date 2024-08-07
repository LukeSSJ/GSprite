extends MarginContainer

signal pressed

onready var Name = $Content/VBox/Name
onready var Colors = $Content/VBox/Colors

onready var PaletteColor = preload("res://ui/PaletteColor.tscn")

func _ready():
	connect("gui_input", self, "gui_input")


func set_data(palette: Dictionary) -> void:
	Name.text = palette.name
	
	var i := 1
	for color in palette.colors:
		var paletteColor = PaletteColor.instance()
		Colors.add_child(paletteColor)
		paletteColor.mouse_filter = MOUSE_FILTER_PASS
		paletteColor.set_number_and_color(i, color)
		i += 1


func gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("pressed")
