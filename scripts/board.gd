extends GridMap

@export var animationPlayer: AnimationPlayer

var grid = []
var grid_width = 8
var grid_height = 8

var currentPiece: Piece
var is_player_turn: bool = true
var jumpAvailable: bool = false
var piece_mid_jump: Piece

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
	
	wire_pieces_to_board()
	
func wire_pieces_to_board():
	for child in get_children():
		if child is Piece:
			child.check_moves.connect(_on_check_moves.bind(child))
			grid[child.grid_position.x][child.grid_position.y] = child.type

func _on_check_moves(piece: Piece):
	#prevent showing moves for phantoms - clicking phantoms should instead trigger the move, not show moves
	if (piece_mid_jump == null or piece == piece_mid_jump) and (jumpAvailable and piece.canJump) or !jumpAvailable and ((is_player_turn and piece.type == enums.piece_types.PLAYER) or (!is_player_turn and piece.type == enums.piece_types.OPPONENT)):
		currentPiece = piece
		currentPiece.piece_selected()
		show_all_available_moves()
	else:
		remove_phantoms()

func show_all_available_moves():
	#resets for clicking a new piece
	remove_phantoms()
	jumpAvailable = false
	
	#returns all valid move placements
	var pieces = get_possibible_moves(currentPiece)
	
	#show all valid moves
	for p: Piece in pieces:
		p.make_move.connect(_on_make_move.bind(p))
		add_child(p)

func get_directional_phantom_piece(parentPiece: Piece, v:Vector2) -> Piece:
	var finalPiece: Piece = null
	var p = Piece.new_piece(enums.piece_types.PHANTOM, Vector2(parentPiece.grid_position.x+v.x,parentPiece.grid_position.y+v.y))
	if is_valid_coord(p.grid_position) and no_obstructions(p.grid_position):
		finalPiece = p
	else:
		if is_valid_coord(p.grid_position) and opponent_within_poximity(parentPiece.type, p.grid_position): #check if piece was in bounds - no point in checking past that point if its not
			p = Piece.new_piece(enums.piece_types.PHANTOM_JUMP, Vector2(parentPiece.grid_position.x+v.x+v.x,parentPiece.grid_position.y+v.y+v.y))
			if is_valid_coord(p.grid_position) and no_obstructions(p.grid_position):
				if is_valid_coord(p.grid_position):
					finalPiece = p
					finalPiece.canJump = true
					if !jumpAvailable:
						jumpAvailable = true
				else: 
					finalPiece = null
			else: #must be out of bounds, thus invalid
				finalPiece = null
	return finalPiece

func get_possibible_moves(piece: Piece) -> Array:
	#All possible starting directions
	var move_possibilites: Array = []
	var northward_moves = [
		Vector2(+1,+1),
		Vector2(-1,+1)
	]
	var southward_moves = [
		Vector2(-1,-1),
		Vector2(+1,-1)
	]
	
	#assign directional movement based on player type since they move in opposing directions
	if piece.type == enums.piece_types.PLAYER:
		move_possibilites.append_array(northward_moves)
	if piece.type == enums.piece_types.OPPONENT:
		move_possibilites.append_array(southward_moves)
	
	#add the addition movement direction once kinged
	if piece.isKinged:
		if piece.type == enums.piece_types.PLAYER:
			move_possibilites.append_array(southward_moves)
		if piece.type == enums.piece_types.OPPONENT:
			move_possibilites.append_array(northward_moves)
	
	#get all possible, non-blocked, moves
	var non_blocked_pieces: Array = []
	for move in move_possibilites:
		var phantom = get_directional_phantom_piece(piece, move)
		if phantom != null:
			non_blocked_pieces.append(phantom)
	
	#looping through again in case jump is found - in that case, only jumps are valid movements to be added to the final array
	var valid_pieces: Array = []
	for p: Piece in non_blocked_pieces:
		if (!jumpAvailable or p.type == enums.piece_types.PHANTOM_JUMP):
			valid_pieces.append(p)
			
	return valid_pieces
	
func _on_make_move(piece: Piece):
	currentPiece.place_piece()
	remove_phantoms()
	
	jumpAvailable = false
	var jumpedPiece = try_make_jump(piece)
	
	sync_movement_with_virtual_board(piece)
	check_win()
	
	get_possibible_moves(currentPiece) #reruns the simulation for possible moves - sets jumpAvailable = true if there are available jumps to make
	clear_required_jumps()
	
	if jumpedPiece and jumpAvailable: #this allows for double, triple, etc. jumps
		show_all_available_moves()
		piece_mid_jump = piece
	else:
		piece_mid_jump = null
		jumpAvailable = false
		check_if_kinged()
		change_turn()
		check_for_jumps()
	
	
func remove_phantoms():
	for child in get_children():
		if child is Piece:
			if child.type == enums.piece_types.PHANTOM or child.type == enums.piece_types.PHANTOM_JUMP:
				remove_child(child)

func printGrid():
	for g in grid:
		print(g)

#checks if an opponent piece has been jumped - returns [true] if yes, [false] if no
func try_make_jump(piece: Piece) -> bool:
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
	
func get_forward_direction() -> int:
	if currentPiece.type == enums.piece_types.OPPONENT:
		return -1
	else:
		return 1
	
func check_win():
	for child in get_children():
		if child is Piece:
			if child.type != currentPiece.type:
				return			
	print(str("the winner is ", currentPiece.type))

func is_valid_coord(p: Vector2) -> bool:
	var result = false
	if p.x >= 0 and p.x < grid_width and p.y >= 0 and p.y < grid_height:
		result = true
	return result

func no_obstructions(p: Vector2) -> bool:
	return grid[p.x][p.y] is String# or grid[p.x][p.y] != currentPiece.type

func opponent_within_poximity(friendlyType: enums.piece_types, p: Vector2) -> bool:
	return grid[p.x][p.y] is int and grid[p.x][p.y] != friendlyType
	
func check_if_kinged():
	if currentPiece.type == enums.piece_types.PLAYER and currentPiece.grid_position.y == grid_height-1:
		currentPiece.isKinged = true;
	elif currentPiece.type == enums.piece_types.OPPONENT and currentPiece.grid_position.y == 0:
		currentPiece.isKinged = true;
		
func sync_movement_with_virtual_board(piece: Piece):
	grid[currentPiece.grid_position.x][currentPiece.grid_position.y] = ""
	grid[piece.grid_position.x][piece.grid_position.y] = currentPiece.type
	currentPiece.set_pos_from_grid(piece.grid_position)

func check_for_jumps():
	var all_children = get_children()
	for child in all_children:
		if child is Piece and (is_player_turn and child.type == enums.piece_types.PLAYER) or (!is_player_turn and child.type == enums.piece_types.OPPONENT):
			var moves = get_possibible_moves(child)
			for m:Piece in moves:
				if m.canJump:
					child.canJump = true
					child.apply_materials()

func clear_required_jumps():		
	for child in get_children():
		if child is Piece:
			child.canJump = false
			child.apply_materials()
