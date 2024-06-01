extends Node3D

@export var winner_animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	winner_animation.play("winner_showcase")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
