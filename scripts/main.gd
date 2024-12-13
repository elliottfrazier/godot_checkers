extends Node3D

@export var animationPlayer: AnimationPlayer
@export var centerContainer: CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	centerContainer.game_started.connect(startGame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startGame():
	animationPlayer.play("camera/start_game")

