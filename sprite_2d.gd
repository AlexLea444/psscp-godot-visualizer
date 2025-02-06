extends Sprite2D


var images = [
	preload("res://bird.svg"),
	preload("res://frog.svg"),
]

@export var circle_radius = 200.0	
@export var current_angle = 0.0	

@export var circle_center: Vector2 = Vector2(0, 0)	



func _ready():
	# Set a default image
	texture = images[1]
	move_to_angle(0)


func move_to_angle(degrees: float):
	var radians = deg_to_rad(degrees)
	current_angle = degrees	
	position = circle_center + Vector2(
		cos(radians) * circle_radius,
		sin(radians) * circle_radius
	)

var current_index = 0


func _input(event):
	if event.is_action_pressed("ui_right"):
		current_index = (current_index + 1) % images.size()
		#texture = images[current_index]
		
		move_to_angle(int(current_angle + 30) % 360)
		
