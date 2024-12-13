class_name Piece
extends StaticBody3D

signal check_moves 
signal make_move

@export var grid_position: Vector2
@export var mesh: MeshInstance3D
@export var kingMesh: MeshInstance3D

@export var placePieceStream: AudioStreamPlayer3D
@export var clickPieceStream: AudioStreamPlayer3D
@export var invalidPieceStream: AudioStreamPlayer3D

var oppMaterial: Material = preload("res://textures/opponent_piece.tres")
var yourMaterial: Material = preload("res://textures/player_piece.tres")
var phantomMaterial: Material = preload("res://textures/phantom_piece.tres")
var playerJumpMaterial: Material = preload("res://textures/player_jump_piece.tres")
var opponentJumpMaterial: Material = preload("res://textures/opponent_jump_piece.tres")

const enums = preload("res://scripts/enums.gd")

var type
var isKinged = false
var canJump: bool = false

const piece_scene: PackedScene = preload("res://scenes/checker_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_materials()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		pass
	
static func new_piece(pieceType, pos: Vector2) -> Piece:
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
	if type == enums.piece_types.PHANTOM or type == enums.piece_types.PHANTOM_JUMP:
		make_move.emit()
	else:
		check_moves.emit()

func apply_materials():
	match type:
		enums.piece_types.OPPONENT:
			mesh.set_surface_override_material(0, oppMaterial)
			kingMesh.set_surface_override_material(0, oppMaterial)
			if canJump:
				mesh.set_surface_override_material(0, opponentJumpMaterial)
				kingMesh.set_surface_override_material(0, opponentJumpMaterial)
		enums.piece_types.PLAYER:
			mesh.set_surface_override_material(0, yourMaterial)
			kingMesh.set_surface_override_material(0, yourMaterial)
			if canJump:
				mesh.set_surface_override_material(0, playerJumpMaterial)
				kingMesh.set_surface_override_material(0, playerJumpMaterial)
		enums.piece_types.PHANTOM:
			mesh.set_surface_override_material(0, phantomMaterial)
			kingMesh.set_surface_override_material(0, phantomMaterial)
		enums.piece_types.PHANTOM_JUMP:
			mesh.set_surface_override_material(0, phantomMaterial)
			kingMesh.set_surface_override_material(0, phantomMaterial)
		enums.piece_types.KILL:
			pass
	

func place_piece():
	placePieceStream.play()
	
func piece_selected():
	clickPieceStream.play()
	
func piece_invalid():
	invalidPieceStream.play()
	
func piece_kinged():
#this method is not being called anywhere right now
#not showing new mesh in scene - idk why
	kingMesh.show()
	
func set_type(newType: enums.piece_types):
	type = newType
	apply_materials()
