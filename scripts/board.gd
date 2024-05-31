extends GridMap

@export var animationPlayer: AnimationPlayer

var grid = []
var grid_width = 8
var grid_height = 8

var currentPiece: Piece
var is_player_turn = true
var jump_piece
var extraTurn
var jumpAvailable

const enums = preload("res://scripts/enums.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_board()
	setup_pieces()
	animationPlayer.play("camera/start_game")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generate_board():
	#Genrate mesh grid
	var tile = 0
	for x in grid_width:
		tile+=1
		for z in grid_height:
			tile+=1
			var t = 0 if (tile % 2) == 0 else 1
			set_cell_item(Vector3i(x,0,z), t)
	#Generate virtual grid	
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append("")
			
func setup_pieces():
	reset_pieces()		
	printGrid()
	
func reset_pieces():
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(0,0)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(2,0)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(4,0)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(6,0)))
	
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(1,1)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(3,1)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(5,1)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(7,1)))
	
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(0,2)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(2,2)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(4,2)))
	add_child(Piece.new_piece(enums.piece_types.PLAYER, Vector2(6,2)))
	
	#Opponent pieces:
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(1,7)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(3,7)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(5,7)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(7,7)))
	
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(0,6)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(2,6)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(4,6)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(6,6)))
	
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(1,5)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(3,5)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(5,5)))
	add_child(Piece.new_piece(enums.piece_types.OPPONENT, Vector2(7,5)))
	
	connect_pieces()
	
func connect_pieces():
	for child in get_children():
		if child is Piece:
			child.check_moves.connect(_on_check_moves.bind(child))
			grid[child.grid_position.x][child.grid_position.y] = child.type

func _on_check_moves(piece: Piece):
	currentPiece = piece
	if (is_player_turn and piece.type == enums.piece_types.PLAYER) or (!is_player_turn and piece.type == enums.piece_types.OPPONENT):
		show_all_available_moves()

func show_all_available_moves():
	remove_phantoms()
	currentPiece.piece_selected()
	jumpAvailable = false
	var move_possibilites: Array = []
	
	var north_moves = [
		Vector2(+1,+1),
		Vector2(-1,+1)
	]
	var south_moves = [
		Vector2(-1,-1),
		Vector2(+1,-1)
	]
	
	if currentPiece.type == enums.piece_types.PLAYER:
		move_possibilites.append_array(north_moves)
	if currentPiece.type == enums.piece_types.OPPONENT:
		move_possibilites.append_array(south_moves)
	if currentPiece.isKinged:
		if currentPiece.type == enums.piece_types.PLAYER:
			move_possibilites.append_array(south_moves)
		if currentPiece.type == enums.piece_types.OPPONENT:
			move_possibilites.append_array(north_moves)
		
	var pieces: Array = []
	for move in move_possibilites:
		pieces.append(get_possibible_moves(move))

	for p: Piece in pieces:
		if (is_valid_coord(p.grid_position) and !jumpAvailable) or (is_valid_coord(p.grid_position) and p.type == enums.piece_types.PHANTOM_JUMP):
			p.make_move.connect(_on_make_move.bind(p))
			add_child(p)
	
func get_possibible_moves(v:Vector2) -> Piece:
	var p = Piece.new_piece(enums.piece_types.PHANTOM, Vector2(currentPiece.grid_position.x+v.x,currentPiece.grid_position.y+v.y))
	if !is_valid_coord(p.grid_position):
		p = Piece.new_piece(enums.piece_types.PHANTOM_JUMP, Vector2(currentPiece.grid_position.x+v.x+v.x,currentPiece.grid_position.y+v.y+v.y))
		if !jumpAvailable:
			jumpAvailable = is_valid_coord(p.grid_position)
	return p
	
func _on_make_move(piece: Piece):
	remove_phantoms()
	var jumpedPiece = try_for_jump(piece)
	grid[currentPiece.grid_position.x][currentPiece.grid_position.y] = ""
	grid[piece.grid_position.x][piece.grid_position.y] = currentPiece.type
	currentPiece.set_pos_from_grid(piece.grid_position)
	currentPiece.place_piece()
	check_win()
	if jumpedPiece and check_for_future_jumps():
		show_all_available_moves()
	else:
		change_turn()
	
	
func remove_phantoms():
	for child in get_children():
		if child is Piece:
			if child.type == enums.piece_types.PHANTOM or child.type == enums.piece_types.PHANTOM_JUMP:
				remove_child(child)

func printGrid():
	for g in grid:
		print(g)

func try_for_jump(piece: Piece) -> bool:
	var x = (piece.grid_position.x + currentPiece.grid_position.x) / 2
	var y = (piece.grid_position.y + currentPiece.grid_position.y) / 2
	var jumpPiece = Vector2(x,y)
	if grid[jumpPiece.x][jumpPiece.y] is int and grid[jumpPiece.x][jumpPiece.y] != currentPiece.type:
		for child in get_children():
			if child is Piece:
				if child.grid_position == jumpPiece:
					remove_child(child)
					grid[jumpPiece.x][jumpPiece.y] = ""
					return true
	return false
					
func change_turn():
	if is_player_turn:
		is_player_turn = false
		animationPlayer.play("camera/rotate_camera_opponent")
	else:
		animationPlayer.play("camera/rotate_camera_player")
		is_player_turn = true
	
	
func check_for_jump_right(piece) -> bool:
	return piece.x < grid_width-1 and piece.y < grid_height-1 and grid[piece.x][piece.y] is int and grid[piece.x][piece.y] != currentPiece.type and grid[piece.x-get_forward_direction()][piece.y+get_forward_direction()] is String

func check_for_jump_left(piece) -> bool:
	return piece.x < grid_width-1 and piece.y < grid_height-1 and grid[piece.x][piece.y] is int and grid[piece.x][piece.y] != currentPiece.type and grid[piece.x-get_forward_direction()][piece.y+get_forward_direction()] is String

func get_phantom_loc_NE() -> Vector2:
	return Vector2(currentPiece.grid_position.x-1,currentPiece.grid_position.y+get_forward_direction())

func get_phantom_loc_NW() -> Vector2:
	return Vector2(currentPiece.grid_position.x+1,currentPiece.grid_position.y+get_forward_direction())

func get_forward_direction() -> int:
	if currentPiece.type == enums.piece_types.OPPONENT:
		return -1
	else:
		return 1
		
func check_for_future_jumps() -> bool:
	var ne = get_phantom_loc_NE()
	var nw = get_phantom_loc_NW()
	return check_for_jump_right(ne) or check_for_jump_left(nw)
	
func check_win():
	for child in get_children():
		if child is Piece:
			if child.type != currentPiece.type:
				return			
	print(str("the winner is ", currentPiece.type))

func is_valid_coord(p: Vector2) -> bool:
	var result = false
	if p.x >= 0 and p.x < grid_width and p.y >= 0 and p.y < grid_height and grid[p.x][p.y] is String:
		result = true
	return result
