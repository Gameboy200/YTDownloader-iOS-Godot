extends Panel

func _ready():
	var button = $TextureButton
	button.connect("pressed", self, "_button_pressed")

func _button_pressed():
	var clipboard_text = OS.get_clipboard()
	var line_edit = $LineEdit
	# Set the text of the LineEdit
	line_edit.text = clipboard_text
