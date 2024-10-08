extends CharacterBody2D

@export_category("Upgrades")
@export var hasJetpack : bool = true
@export var hasWheel : bool = true

@export_category("Movement")
@export var speed = 200.0
@export var jumpVelocity = -300.0
@export var jetpackVelocity = -100.0
@export var dashModifier = 5
@export var dashLength = 0.15 # Seconds
@export var friction = 0.07
@export var coyoteTime = 0.1 # Seconds

@onready var Main = get_node("/root/Main")
@onready var Bot = $Bot/AnimatedSprite2D
@onready var Wheel = $Wheel/Sprite2D
@onready var Jetpack = $Jetpack/Sprite2D
@onready var DeathSound = $DeathSound

var inputEnabled : bool = true
var canJump : bool = true

var dashTime : float = 0.0
var floorCooldown : float = 0.0
var _speed
var spawnLocation: Vector2
var justDied = false
var directions = ["left", "front", "right"]


func _ready() -> void:
	spawnLocation = position
	if !hasJetpack:
		remove_child($Jetpack)
	if !hasWheel:
		remove_child($Wheel)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		die()

func _physics_process(delta: float) -> void:
	if justDied:
		pause()
		await get_tree().create_timer(0.1).timeout
		resume()
		justDied = false
	if inputEnabled: 
		handle_movement(delta)
	damage()


func die():
	Main.deaths += 1
	DeathSound.play()
	position = spawnLocation
	justDied = true


func pause():
	Jetpack.frame = 1
	Bot.animation = "front"
	velocity = Vector2()
	inputEnabled = false

func resume():
	inputEnabled = true


func damage() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("danger"):
			die()
			break


func handle_movement(delta):
	## Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	## Coyote Time
	if floorCooldown > 0.0:
		floorCooldown -= delta
	if is_on_floor():
		floorCooldown = coyoteTime
	
	
	## Boost
	if dashTime > 0.0:
		dashTime -= delta
	if dashTime <= 0.0 and is_on_floor():
		dashTime = -1.0
	if dashTime > 0.0 :
		_speed = move_toward(_speed, speed * dashModifier, 100)
	else:
		_speed = speed
	if Input.is_action_just_pressed("Dash") and has_node("Wheel") and dashTime <= -1.0:
		dashTime = dashLength
	
	
	## Input
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed*friction)
	
	
	## Jump
	if Input.is_action_just_pressed("Jump") and canJump and floorCooldown > 0.0:
		velocity.y = jumpVelocity
	
	
	## Jetpack
	Jetpack.frame = direction+1
	if Input.is_action_pressed("Jump") and canJump and has_node("Jetpack") and !floorCooldown > 0.0 and position.y > -256:
		velocity.y = jetpackVelocity
		Jetpack.frame += 3
	
	
	## Animation
	Bot.animation = directions[direction+1]
	Wheel.rotation += velocity.x / 1000
	
	move_and_slide()
