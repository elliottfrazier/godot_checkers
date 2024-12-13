extends CenterContainer
@export var MenuOptions: VBoxContainer
@export var SettingsOptions: VBoxContainer
@export var GameModes: VBoxContainer
@export var AudioPlayer: AudioStreamPlayer
@export var buttonSoundStream: AudioStreamPlayer3D

signal game_started

const globalLogic = preload("res://scripts/global.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	MenuOptions.visible = true
	SettingsOptions.visible = false
	GameModes.visible = false
	_on_h_slider_value_changed(75)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_pressed():
	playBtnSound()
	GameModes.visible = true
	MenuOptions.visible = false
	
func toggleMenu():
	visible = !visible

func _on_exit_pressed():
	playBtnSound()
	get_tree().quit()


func _on_settings_pressed():
	playBtnSound()
	toggleSettings()
	
func toggleSettings():
	SettingsOptions.visible = !SettingsOptions.visible
	MenuOptions.visible = !MenuOptions.visible


func _on_back_pressed():
	#A queue system could be implemented to keep track of the 
	#menu stack for going back and forth through menu states, 
	#but thats overkill right now for this small project
	playBtnSound()
	GameModes.visible = false
	SettingsOptions.visible = false
	MenuOptions.visible = true


func _on_h_slider_value_changed(value):
	var calcVol: float = (value-80)/5
	print(str("calc val : ", calcVol))
	AudioPlayer.volume_db = calcVol
	if(calcVol <= -16):
		AudioPlayer.volume_db = -100


func _on_single_player_pressed():
	playBtnSound()
	startGame()
	
func startGame():
	toggleMenu()
	game_started.emit()
	
func playBtnSound():
	buttonSoundStream.play()
	
