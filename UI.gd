extends Node2D

var inputted = false
var button_press = false

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
		

 # Replace with your URL
 # Replace with desired output path

func progress():
	var http_reques = HTTPRequest.new()
	var progre = $Panel3
	add_child(http_reques)
	http_reques.connect("request_completed", self, "_on_request_got")
	http_reques.request("http://192.168.0.95:5000/progress")
	progre.visible = true

func _on_request_got(result: int, response_code: int, headers: Array, body: PoolByteArray):
	if response_code == 200:
		# Convert the body from PoolByteArray to a String
		var progre = $Panel3
		var progret = $Panel3/Label
		var response_body = body.get_string_from_utf8()
		var json_result = JSON.parse(response_body)
		var response_dict = json_result.result
		var stage = response_dict.get("stage", "Unknown")
		print(stage)
		progret.text = stage
		if not stage == 'Sending':
			yield(sleep(1.0), "completed")
			progress()
		else:
			progre.visible = false
	else:
		print("Request failed. Response code: ", response_code)

var output_file_path
var no_user

func download_mp4(url, ytt):
	if not button_press:
		output_file_path = "user://" + ytt + ".mp4"
		no_user = ytt + ".mp4"
		print(output_file_path)
		print(no_user)
		yield($Button, "pressed")
		var button_press = true
		# Create and configure HTTPRequest instance
		var http_request = HTTPRequest.new()
		add_child(http_request)  # Add it to the scene tree
		http_request.connect("request_completed", self, "_on_d_request_completed")
	
		# Create the POST request
		var header = ["Content-Type: text/plain"]
		var body = url  # Add your POST data here if needed
		var url2 = "http://192.168.0.95:5000/download"
		# Send the request
		var error = http_request.request(url2, header, false, HTTPClient.METHOD_POST, body)
	
		if error != OK:
			print("Failed to send request.")
		else:
			print("Request sent, waiting for response...")
			yield(sleep(2.0), "completed")
			progress()

func _on_d_request_completed(result, response_code, headers, body):
	var button_press = true
	if response_code == 200:
		# Successfully received response
		var file = File.new()
		print(output_file_path)
		if file.open(output_file_path, File.WRITE) == OK:
			file.store_buffer(body)
			file.close()
			print("File downloaded and saved to: " + output_file_path)
			button_press = false
			share_file(no_user)
		else:
			print("Failed to open file for writing.")
			button_press = false
	else:
		print("Request failed with response code: ", response_code)
		button_press = false

func share_file(filename: String):
	var full_path = OS.get_user_data_dir().plus_file(filename)
	print(full_path)
	var path = "user://" + filename
	if OS.has_feature("mobile"):
		return OS.get_user_data_dir()
	else:
		print("Sharing files is only supported on mobile platforms.")
		return OS.get_environment("USERPROFILE") + "/Downloads"
		

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
	

func sleep(duration):
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(duration)
	timer.set_one_shot(true)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()  # Convert PoolByteArray to String
		var response = JSON.parse(body_string)
		var title = get_node("Label")
		var desc = get_node("Label2")
		if response.error == OK:
			var stage = response.result
			var ytt = stage['title']
			ytt = ytt.replace('Title: ', "")
			print(ytt)
			ytt = ytt.replace("\n", " ").replace("\r", "")
			print(ytt)
			title.text = stage['title']
			desc.text = stage['desc']
			print(stage['thumbnail'])
			set_tex_image(stage['thumbnail'])
			inputted = true
			download_mp4(stage['url'], ytt)
		else:
			print("Error: Unable to parse JSON response")
	else:
		print("Error: Unable to fetch progress (%d)" % response_code)


