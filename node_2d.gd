extends Node2D

# TCP Socket for communication
var socket = StreamPeerTCP.new()

# Visualization parameters
var user_position = Vector2.ZERO
var circle_radius = 200  # Radius of the speaker circle in pixels
var num_speakers = 8     # Number of speakers evenly placed on the circle
var speaker_positions = []  # Precomputed positions of speakers

func _ready():
	# Connect to MATLAB TCP server
	# Attempt to connect to the MATLAB server
	var result = socket.connect_to_host("127.0.0.1", 5000)
	if result == OK:
		print("Connection attempt started.")
	else:
		print("Failed to start connection.")
	
	# Wait for socket to connect
	while socket.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		await get_tree().create_timer(0.01).timeout
		socket.poll()
	
	# Check if the socket is connected
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print("Successfully connected to the server!")
		send_confirmation()
	else:
		print(socket.get_status())
		print("Unable to connect to the server.")

	# Precompute speaker positions on the circle
	for i in range(num_speakers):
		var angle = i * (2 * PI / num_speakers)  # Angle in radians
		var x = circle_radius * cos(angle)
		var y = circle_radius * sin(angle)
		speaker_positions.append(Vector2(x, y))

func send_confirmation():
	# Send a confirmation message to the server
	var message = "READY\n"
	socket.put_data(message.to_utf8_buffer())  # Send "READY" message
	print("Confirmation message sent to server.")

func _process(_delta):
	# Receive and parse data from MATLAB
	if socket.get_available_bytes() > 0:
		var data = socket.get_utf8_string(socket.get_available_bytes())
		var json = JSON.new()
		var parse_result = json.parse(data)
		if parse_result == OK:
			var result = json.get_data()
			if result.has("radius") and result.has("angle"):
				update_user_position(result.radius, result.angle)

	# Redraw the scene
	queue_redraw()

func update_user_position(radius, angle_degrees):
	# Convert polar to Cartesian coordinates
	var angle_radians = deg_to_rad(angle_degrees)
	var x = radius * (circle_radius / 1200.0) * cos(angle_radians)  # Scale radius to fit
	var y = -radius * (circle_radius / 1200.0) * sin(angle_radians)
	user_position = Vector2(x, y)

func _draw():
	# Draw the circle of speakers
	draw_circle(Vector2.ZERO, circle_radius, Color(1, 1, 1, 0.1))  # Circle outline
	for speaker_pos in speaker_positions:
		draw_circle(speaker_pos, 10, Color(1, 0, 0))  # Draw each speaker as a red dot
	
	# Draw the user's position
	draw_circle(user_position, 10, Color(0, 1, 0))  # User's position as a green dot
	draw_line(Vector2.ZERO, user_position, Color(0, 1, 0), 2)  # Line from center to user
