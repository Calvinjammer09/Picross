extends TileMap


@onready var first_move_timer = get_node("InitialMoveTimer")
@onready var fast_move_timer = get_node("MoveTimer")
@onready var test_sprite = get_node("Pickaxe")

var tile_size := 16

var can_move := true
var moving := false
var last_input : Array = [0, 0, 0, 0]
var last_movement_x := 0
var last_movement_y := 0

var current_image_size := Vector2 (11, 11)

func _ready():
	pass
	# replace with code for generating tilemap with image
	
func get_map():

	# map is initially an empty array
	var map = []

	# get image data
	var image = test_sprite.texture.get_data()

	# lock the image so get_pixel() can be called on it
	image.lock()

	# add non-transparent pixel coordinates to map
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x,y)[3] != 0:
				map.append(Vector2(x,y))
	
	return map

func check_last_direction(input):
	if input == last_input:
		last_input = input
		return false
		
	if not input:
		last_input = input
		return false
		
	var input_idx := 0
	var different_directions := []
	
	for direction in input:
		if direction != last_input[input_idx]:
			different_directions.append(input_idx)
			
	last_input = input
			
	return different_directions

func take_input():
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	var got_escape = Input.is_action_pressed('quit')
	if got_escape:
		get_tree().quit()

	var _break_check = Input.is_action_pressed('break')
	var _mark = Input.is_action_pressed('mark')

	var input_list = [1 if direction[0] < 0 else 0, 1 if direction[0] > 0 else 0, 1 if direction[1] < 0 else 0, 1 if direction[1] > 0 else 1]
	
	var input = check_last_direction(input_list)
	
	var dir = direction[0] != 0 or direction[1] != 0

	if dir:
		if can_move:
			if moving:
				fast_move_timer.start()
			else:
				first_move_timer.start()
				moving = true

	else:
		moving = false

	if can_move and dir:
		test_sprite.position += direction.normalized() * tile_size
		can_move = false
		print('moving')

func _physics_process(_delta):
	take_input()
	
func _on_initial_move_timer_timeout():
	can_move = true

func _on_move_timer_timeout():
	can_move = true
