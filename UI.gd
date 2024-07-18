extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var line_edit_node = get_node("Panel/LineEdit")
	var button = get_node("Button")  # Adjust the path if necessary
	#line_edit_node.connect("text_entered", self, "_on_LineEdit_text_entered")
# This function is called when the button is pressed
func _on_LineEdit_text_entered(url1):  # Adjust the path if necessary
	print(1)
	var line_edit_node = get_node("Panel/LineEdit")
	var url = url1
	check_progress(url)

func check_progress(url):
	var endpoint = "http://192.168.0.95:5000/parce"  # Replace with your server address
	var headers = ["Content-Type: text/plain"]  # Use text/plain for raw text data
	var request_body = url  # Sending raw text

	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.connect("request_completed", self, "_on_request_completed")
	var error = http_request.request(endpoint, headers, true, HTTPClient.METHOD_POST, request_body)

	if error != OK:
		print("Error: Unable to send request")
		

func set_tex_image(url):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(url)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	var texture_rect = get_node("Panel2/TextureRect")
	texture_rect.texture = texture
	texture_rect.rect_position = Vector2(5, 5)
	texture_rect.rect_size = Vector2(374, 206)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()  # Convert PoolByteArray to String
		var response = JSON.parse(body_string)
		var title = get_node("Label")
		var desc = get_node("Label2")
		if response.error == OK:
			var stage = response.result
			title.text = stage['title']
			desc.text = stage['desc']
			print(stage['thumbnail'])
			set_tex_image(stage['thumbnail'])
			print("Current stage: %s" % stage)
		else:
			print("Error: Unable to parse JSON response")
	else:
		print("Error: Unable to fetch progress (%d)" % response_code)


