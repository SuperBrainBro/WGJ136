extends KinematicBody2D
class_name Player

export var recoil: Vector2 = Vector2.ZERO
export (int) var speed = 200

signal died()

onready var collider: CollisionShape2D = $CollisionShape2D

const FIREBALL_SCENE: PackedScene = preload("res://Fireball/Fireball.tscn")

onready var player1: Player = $"/root/Main/World/PlayerHolder/Player1"
onready var player2: Player = $"/root/Main/World/PlayerHolder/Player2"

export var linear_velocity: Vector2

export var velocity: Vector2
export var is_active: bool = true
export var health: float = 200
export var damage: float = 1
export var is_frostbite: bool
export var acceleration: float
export var intendedFireMode: bool = false
export var is_dead: bool = false
export var can_penetrate: bool

export var followMouse: bool = true
export var has_key: bool = false

onready var recoilTimer: Timer = $Recoil
onready var spr: Sprite = $Sprite
onready var cam: CameraMain = $"/root/Main/World/Camera/NewCamera"
var health_bar: TextureProgress

func _ready() -> void:
	health = 500

func _process(_delta: float) -> void:
	if is_frostbite:
		health_bar = $"/root/Main/CanvasLayer/Control/HealthBarIce"
	else:
		health_bar = $"/root/Main/CanvasLayer/Control/HealthBarFire"
	($ActiveArrow as Sprite).visible = is_active
	health_bar.value = health
	if health <= 0:
		is_dead = true
		emit_signal("died")
	if is_dead: #player1.is_dead and player2.is_dead
		#($"../../../ScoreTimer" as Timer).stop()
		$"../../../CanvasLayer/Control/GameOverScreen".show()
	if is_dead:
		return
	
	if Input.is_action_just_pressed("attack") and is_active:
		mouseShoot()
	if Input.is_action_just_pressed("shoot_left") and is_active:
		directionalShoot(Vector2(-1, 0))
	if Input.is_action_just_pressed("shoot_right") and is_active:
		directionalShoot(Vector2(1, 0))
	if Input.is_action_just_pressed("shoot_up") and is_active:
		directionalShoot(Vector2(0, -1))
	if Input.is_action_just_pressed("shoot_down") and is_active:
		directionalShoot(Vector2(0, 1))
		
func _physics_process(_delta):
	if not is_active:
		if is_frostbite:
			player2.collider.scale = Vector2(1, 1)
			player1.collider.scale = Vector2(.025, .025)
			player1.z_index = 0
			player2.z_index = 1
			linear_velocity = position.direction_to(player2.position)
			spr.look_at(player2.position)
			linear_velocity = linear_velocity.normalized() * (250)
		else:
			player2.collider.scale = Vector2(.025, .025)
			player1.collider.scale = Vector2(1, 1)
			player2.z_index = 0
			player1.z_index = 1
			linear_velocity = position.direction_to(player1.position)
			spr.look_at(player1.position)
			linear_velocity = linear_velocity.normalized() * (250)
		if is_dead:
			return
# warning-ignore:return_value_discarded
		move_and_slide(linear_velocity)
		return
	if is_dead:
		return
	if followMouse:
		spr.look_at(get_global_mouse_position())
		
	get_input()
	velocity = move_and_slide(velocity + recoil)
	
func directionalShoot(pos: Vector2):
	var fireball = FIREBALL_SCENE.instance()
	fireball.direction = pos
	followMouse = false
	spr.look_at(position+pos)
	fireball.position = position
	fireball.fireMode = intendedFireMode
	fireball.can_penetrate = can_penetrate
	fireball.damage = damage
	$"../../FireballHolder".add_child(fireball)
	cam.shake(0.3,64,11)
	recoilTimer.start(.1)
	recoil = -pos * speed/2.5

func mouseShoot():
	var fireball = FIREBALL_SCENE.instance()
	fireball.direction = position.direction_to(get_global_mouse_position())
	followMouse = true
	fireball.position = position
	fireball.fireMode = intendedFireMode
	fireball.can_penetrate = can_penetrate
	fireball.damage = damage
	$"../../FireballHolder".add_child(fireball)
	cam.shake(0.3,64,11)
	recoilTimer.start(.1)
	recoil = -fireball.direction * speed/2.5

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _on_Recoil_timeout():
	print("Recoil Done ")
	recoil = Vector2.ZERO
