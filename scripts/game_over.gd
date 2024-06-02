extends Node3D

@export var anim_player: AnimationPlayer
#var frame_count: int = 2
#var anim_length: float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.winner_piece.position = Vector3(0,0,0)
	Global.winner_piece.rotation.x = 45
	add_child(Global.winner_piece)
	
	#---------------------------------------------------------------------------------------------------
	#	setting animation dynamically - mostly working.  I just need to learn more about Quaternions
	#---------------------------------------------------------------------------------------------------
	
	#var animation = Animation.new()
	#animation.length = anim_length
	#animation.loop_mode = Animation.LOOP_LINEAR
	#
	#var track_id = animation.add_track(Animation.TYPE_ROTATION_3D)
	#animation.rotation_track_insert_key(track_id,0, Quaternion(Vector3(5,5,5).normalized(),1).normalized())
	#animation.rotation_track_insert_key(track_id,2, Quaternion(Vector3(50,10,10).normalized(),1).normalized())
	#animation.track_set_path(track_id, str(Global.winner_piece.get_path(),":",Global.winner_piece.get_name()))
	#
	#for frame_index in frame_count:
		#var time: float = frame_index / float(frame_count) * anim_length
		#animation.track_insert_key(track_id, time, frame_index)
		#Global.winner_piece.rotation.y = 360
	#
	#var anim_lib = anim_player.get_animation_library("game_over")
	#var err = anim_lib.add_animation("winner", animation)
	#
	#anim_player.play("game_over/winner")


	anim_player.play("game_over/winner_showcase")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
