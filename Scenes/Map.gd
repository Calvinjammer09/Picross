extends TileMap



class Puzzle:
	var Name: String
	var Bitmap: Array[String]
	var BoardSize : Vector2
	var BoardState : Array[String]
	
	var Tiles : Array
	var ChiselMode : String
	
	var TileSize := 16
	
	var chisled = load("res://Sprites/Chisled.png")
	var blank = load("res://Sprites/BlankTile.png")
	var marked = load("res://Sprites/Marked.png")
	
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
				
	func print_bitmap():
		for s in Bitmap:
			print(s)
	
	func chisel(tile:Sprite2D, x, y, input:String):
		if ChiselMode == '':
			if tile.texture == chisled and input != 'mark':
				tile.set_texture(blank)
				BoardState[x][y] = ' '
				ChiselMode = 'blank'
			elif tile.texture == blank and input != 'mark':
				tile.set_texture(chisled)
				BoardState[x][y] = 'X'
				ChiselMode = 'chisel'
			elif tile.texture != marked and input == 'mark':
				tile.set_texture(marked)
				ChiselMode = 'mark'
			elif tile.texture == marked:
				tile.set_texture(blank)
				ChiselMode = 'blank'
			
		elif ChiselMode == 'blank':
			if tile.texture != blank:
				tile.set_texture(blank)
				BoardState[x][y] == ' '
				
		elif ChiselMode == 'mark':
			if tile.texture != marked:
				tile.set_texture(marked)
				
		elif tile.texture != chisled:
			tile.set_texture(chisled)

@onready var first_move_timer = get_node('InitialMoveTimer')
@onready var fast_move_timer = get_node('MoveTimer')
@onready var test_sprite = get_node('Pickaxe')
@onready var lava_blob = get_node('LavaMap')
@onready var cursor = get_node('Cursor')

var tile_scale := 2
var tile_size := 16 * tile_scale

var last_tile_chiseled
var last_tile_marked

var puzzle

var chisled = load("res://Sprites/Chisled.png")
var blank = load("res://Sprites/BlankTile.png")

var can_move := true
var moving := false
var last_input : Array = [0, 0, 0, 0]
var last_movement_x := 0
var last_movement_y := 0

func _ready():
	puzzle = generate_map(lava_blob.texture.get_image(), Vector2(20, 20))

func generate_map(image, puzzle_size:Vector2):
	var new_puzzle = Puzzle.new()
	
	new_puzzle.BoardSize = puzzle_size

	for y in image.get_height():
		var line = ''
		var first_board = ''
		for x in image.get_width():
			line += 'X' if image.get_pixel(x, y)[3] != 0 else ' '
			first_board += ' '
		new_puzzle.BoardState.append(first_board)
		new_puzzle.Bitmap.append(line)

	new_puzzle.print_bitmap()
	print("Rows:", new_puzzle.puzzle_rows())
	print("Cols:", new_puzzle.puzzle_cols())
	
	for y in range(new_puzzle.BoardSize[0]):
		var tile_row : Array
		for x in range(new_puzzle.BoardSize[1]):
			var new_brick = Sprite2D.new()
			new_brick.centered = false
			new_brick.position = Vector2(x * tile_size, y * tile_size)
			new_brick.scale = Vector2(tile_scale, tile_scale)

			new_brick.set_texture(blank)
			
			tile_row.append(new_brick)

			add_child(new_brick)
		new_puzzle.Tiles.append(tile_row)

	return new_puzzle
		

func take_input():
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	
	var chisel = Input.is_action_pressed('break')
	var mark = Input.is_action_pressed('mark')
	var got_escape = Input.is_action_pressed('quit')
	
	if got_escape:
		get_tree().quit()
	
	if chisel and mark:
		var pos = (cursor.position + Vector2(1, 1)) / Vector2(tile_size, tile_size)
		puzzle.chisel(puzzle.Tiles[pos[1]][pos[0]], pos[1], pos[0], 'mark')
	
	elif chisel or mark:
		var pos = (cursor.position + Vector2(1, 1)) / Vector2(tile_size, tile_size)
		if chisel:
			
			if pos != last_tile_chiseled:
				last_tile_chiseled = pos
				puzzle.chisel(puzzle.Tiles[pos[1]][pos[0]], pos[1], pos[0], 'chisel')
		else:
			last_tile_chiseled = Vector2(-1, 0)
			
		if mark:
			if pos != last_tile_marked:
				last_tile_marked = pos
				puzzle.chisel(puzzle.Tiles[pos[1]][pos[0]], pos[1], pos[0], 'mark')
		else:
			last_tile_chiseled = Vector2(-1, 0)
			
	else:
		puzzle.ChiselMode = ''

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
		cursor.position += direction.normalized() * tile_size
		can_move = false

func _physics_process(_delta):
	take_input()
	
func _on_initial_move_timer_timeout():
	can_move = true

func _on_move_timer_timeout():
	can_move = true
