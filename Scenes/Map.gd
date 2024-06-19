extends TileMap

class Puzzle:
	var Name: String
	var Bitmap: Array[String]
	
	func puzzle_count(s:String) -> Array[int]:
		'''Given a string representing a row/col, return the pattern'''
		var result: Array[int] = []

		for sp in s.split(" "):
			if 0 != sp.length():
				result.append(sp.length())
				
		if result.size() == 0:
			result = [0]
		
		return result
	
	func puzzle_rows() -> Array:
		'''Given a puzzle, returns an array of arrays of ints
		
		These are the pattern counts for each row
		'''
		var result = []
		for s in Bitmap:
			result.append(puzzle_count(s))
		return result
		
	func puzzle_cols() -> Array:
		'''Does the same thing as puzzle_rows, but for columns
		
		This is a bit complicated as we have to transpose the puzzle
		'''
		var result = []
		
		for i in range(Bitmap[0].length()):
			var s = ""
			for row in Bitmap:
				s += row[i]
			result.append( puzzle_count(s) )
		return result
	

@onready var first_move_timer = get_node("InitialMoveTimer")
@onready var fast_move_timer = get_node("MoveTimer")
@onready var test_sprite = get_node("Pickaxe")
@onready var lava_blob = get_node('LavaMap')

var tile_size := 16

var can_move := true
var moving := false
var last_input : Array = [0, 0, 0, 0]
var last_movement_x := 0
var last_movement_y := 0

var current_image_size := Vector2 (20, 20)

func _ready():
	puzzle_demo()
	generate_map(lava_blob.texture.get_image())

func print_bitmap(p):
	for s in p.Bitmap:
		print(s)

func puzzle_demo():
	var p := Puzzle.new()
	p.Name = "easy puzzle"
	p.Bitmap = [
		" X ", 
		"XXX",
		"X X"]
	
	print_bitmap(p)
	print("Rows:", p.puzzle_rows())
	print("Cols:", p.puzzle_cols())


func generate_map(image):
	var new_puzzle = Puzzle.new()

	for y in image.get_width():
		var line = ''
		for x in image.get_height():
			line += 'X' if image.get_pixel(x, y)[3] != 0 else ' '
		new_puzzle.Bitmap.append(line)
		
	print_bitmap(new_puzzle)
	print("Rows:", new_puzzle.puzzle_rows())
	print("Cols:", new_puzzle.puzzle_cols())
	
			
func check_last_direction(input):
	if input == last_input:
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
	
	var _input = check_last_direction(input_list)
	
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
		can_move = true

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
