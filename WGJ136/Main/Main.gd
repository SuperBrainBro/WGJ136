extends Node
class_name Main

const ENEMY_SCENE: PackedScene = preload("res://Enemy/Enemy.tscn")
const OGRE_SCENE = preload("res://Enemy/Ogre.tscn")
const SKELETON_SCENE = preload("res://Enemy/Skeleton.tscn")
const FIRE_ARCHER_SCENE = preload("res://Enemy/FireArcher.tscn")

onready var player1: Player = $World/PlayerHolder/Player1
onready var player2: Player = $World/PlayerHolder/Player2

#onready var cam1: Camera2D = $World/PlayerHolder/Player1/Camera2D
#onready var cam2: Camera2D = $World/PlayerHolder/Player2/Camera2D

onready var cam: CameraMain = $World/Camera/NewCamera

onready var intendedIntendedFireMode: bool = true;

export var score: int
export var instructions: bool

onready var audioFX: soundFX = $"/root/Main/soundFX"

func _ready() -> void:
	randomize()
	
	player1.is_active = false
	player2.is_active = true
	

	cam.playerCam = not cam.playerCam
	
	player1.intendedFireMode = false
	player2.intendedFireMode = true
	
	if not instructions:
# warning-ignore:return_value_discarded
		$CanvasLayer/Control/GameOverScreen/PlayAgainButton.connect("pressed", self, "_on_PlayAgainButton_Pressed")
	
func _process(_delta: float) -> void:
	if not instructions:
		$CanvasLayer/Control/ScoreLabel.text = "Score: " + str(score)
	if Input.is_action_just_pressed("change_player"):
		print('Switched Player')
		audioFX.playSwitch()
		
		player1.is_active = not player1.is_active
		player2.is_active = not player2.is_active

		cam.playerCam = not cam.playerCam
		
		player1.intendedFireMode = false
		player2.intendedFireMode = true
	
func _on_PlayAgainButton_Pressed() -> void:
	if not instructions:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Main/Main.tscn")
