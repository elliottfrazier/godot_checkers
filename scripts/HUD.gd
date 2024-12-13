class_name HUD
extends BoxContainer

@export var board: Board

signal current_piece_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	board.current_piece_changed.connect(_on_board_grid_map_current_piece_changed)
	#board.connect()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_board_grid_map_current_piece_changed(piece: Piece):
	print(piece)
	current_piece_changed.emit(piece)
