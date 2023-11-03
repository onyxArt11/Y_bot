extends CharacterBody3D


var SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export_range(0,1) var sens_horizontal = 0.5
@export_range(0,1) var sens_vertical = 0.5
@onready var animation_player = $visuals/y_bot/AnimationPlayer
@onready var right_b = $visuals/right_b
@onready var left_b = $visuals/left_b
@onready var crouch_col2 = $crouch2
@onready var camera_mount = $camera_mount
@onready var neck = $camera_mount/neck
@onready var visuals = $visuals

var move = false
var jump = false
var run = false
var crouch = false
var roll = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		camera_mount.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		#visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		neck.rotate_x(-deg_to_rad(event.relative.y * sens_vertical))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if run:
			animation_player.play('Running Jump')
		else:
			animation_player.play("Fall A Loop")
		jump = true
	else:
		jump = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_direction:= Vector3.ZERO
	move_direction.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	move_direction.z = Input.get_action_strength("ui_up") -Input.get_action_strength("ui_down") 
	
	move_direction = move_direction.rotated(Vector3.UP,camera_mount.rotation.y).normalized()
	velocity.x = -move_direction.x * SPEED
	velocity.z = -move_direction.z *SPEED
	
	move_and_slide()
	velocity = velocity
		
	if velocity.length() > 0.2:
		var look_direction =Vector2(-velocity.z, -velocity.x)
		visuals.rotation.y = look_direction.angle()
	
func _process(_delta):
	if !right_b.is_colliding() and !left_b.is_colliding():
		if !jump:
			crouch = true
	else:
		crouch = false

	if !roll:
		crouch_col2.disabled = false
	if !animation_player.is_playing():
		roll = false


	if Input.is_action_pressed("sprint") and !crouch:
		run = true
		SPEED = 5
	else:
		run = false
		SPEED = 1.3

	if Input.is_action_pressed("fire") and !jump and move:
		roll = true
		animation_player.play("roll")
		crouch_col2.disabled = true


	if Input.is_action_pressed('ui_up')||Input.is_action_pressed('ui_down')||Input.is_action_pressed('ui_left')||Input.is_action_pressed('ui_right'):
		move = true
		if !jump and !roll:
			if run:
				animation_player.play('Fast Run')
			elif crouch:
				animation_player.play("Crouch Walk Forward")
			else:
				animation_player.play('Walking')
	else:
		move = false
		if !jump and !crouch:
			animation_player.play("Happy Idle")
		elif crouch:
			animation_player.play("Crouching Idle")
	
