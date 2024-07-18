extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the signal of the LineEdit to a custom function
	var line_edit = $LineEdit
	line_edit.connect("text_entered", self, "_on_LineEdit_text_entered")
	
	# Connect the button signal (optional)
	var button = $Button
	button.connect("pressed", self, "_on_Button_pressed")

# Custom function to handle the LineEdit text entered signal
func _on_LineEdit_text_entered(new_text):
	print(new_text)

# Custom function to handle the button press signal (optional)
func _on_Button_pressed():
	var line_edit = $LineEdit
	var text = line_edit.text
	print(text)
