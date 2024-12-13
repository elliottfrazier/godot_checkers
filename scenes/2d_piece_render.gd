extends TextureRect

@export var piece: Piece
@export var hud: HUD

const enums = preload("res://scripts/enums.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.current_piece_changed.connect(_on_hud_current_piece_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func x(currentPieceType: enums.piece_types):
	piece.set_piece_type(currentPieceType)


func _on_hud_current_piece_changed(changedPiece: Piece):
	piece.set_type(changedPiece.type)
