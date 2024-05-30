class_name Piece
extends StaticBody3D

signal check_moves 
signal make_move

@export var grid_position: Vector2

var oppMaterial: Material = preload("res://textures/opponent_piece.tres")
var yourMaterial: Material = preload("res://textures/your_piece.tres")
var phantomMaterial: Material = preload("res://textures/phantom_piece.tres")

const enums = preload("res://scripts/enums.gd")

var type

const piece_scene: PackedScene = preload("res://checker_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_materials()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		pass
	
static func new_piece(pieceType , pos: Vector2) -> Piece:
	var new_piece: Piece = piece_scene.instantiate()
	new_piece.type = pieceType
	new_piece.set_pos_from_grid(pos)
	return new_piece
	
func set_pos_from_grid(pos: Vector2):
	grid_position = pos
	position.x = pos.x + .5
	position.z = pos.y + .5
	position.y = 0.7

func piece_clicked():
	if type == enums.piece_types.PHANTOM:
		make_move.emit()
	else:
		check_moves.emit()

func apply_materials():
	match type:
		enums.piece_types.OPPONENT:
			$MeshInstance3D.set_surface_override_material(0, oppMaterial)
		enums.piece_types.PLAYER:
			$MeshInstance3D.set_surface_override_material(0, yourMaterial)
		enums.piece_types.PHANTOM:
			$MeshInstance3D.set_surface_override_material(0, phantomMaterial)

func place_piece():
	$placePieceStream.play()
	
func piece_selected():
	$clickPieceStream.play()
