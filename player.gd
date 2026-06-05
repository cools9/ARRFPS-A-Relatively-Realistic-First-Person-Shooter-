extends CharacterBody3D
@onready var raycast=$Camera3D/RayCast3D

@onready var camera: Camera3D = $Camera3D
@onready var bullet_scene = preload("res://scenes/bullet.tscn")

const SPEED = 7.0
const JUMP_VELOCITY = 6.0

var sensitivity = 0.3
var rotation_x = 0.0
var rotation_y = 0.0

# states
var is_sliding = false
var is_crouching = false

var slide_timer = 0.0
var slide_duration = 0.5
var slide_speed_multiplier = 1.5

# movement modifiers
var crouch_speed_multiplier = 0.5

# camera system
var base_camera_y = 0.0
var slide_camera_offset = -0.4
var crouch_camera_offset = -0.2
var current_camera_offset = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	base_camera_y = camera.position.y
	floor_max_angle = deg_to_rad(45)
	floor_snap_length = 0.4


func _physics_process(delta: float) -> void:
	#print(global_position.z)
	if global_position.y < -100:
		global_position=Vector3(330,144,329)
	
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# shoot
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# crouch toggle
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		is_crouching = !is_crouching

		# cancel slide if crouching
		if is_crouching:
			is_sliding = false

	# slide start
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_crouching:
		is_sliding = true
		slide_timer = slide_duration

	# slide timer
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0.0:
			is_sliding = false

	# movement input
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# speed logic
	var speed = SPEED

	if is_sliding:
		speed *= slide_speed_multiplier
	elif is_crouching:
		speed *= crouch_speed_multiplier

	# movement
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# camera logic
	var target_offset := 0.0

	if is_sliding:
		target_offset = slide_camera_offset
	elif is_crouching:
		target_offset = crouch_camera_offset

	current_camera_offset = lerp(current_camera_offset, target_offset, 10.0 * delta)
	camera.position.y = base_camera_y + current_camera_offset

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * sensitivity
		rotation_x -= event.relative.y * sensitivity

		rotation_x = clamp(rotation_x, -90, 90)

		rotation_degrees.y = rotation_y
		camera.rotation_degrees.x = rotation_x


func shoot():
	if raycast.is_colliding():
		var target = raycast.get_collider()
		var hit_pos = raycast.get_collision_point()
		var distance = raycast.global_position.distance_to(hit_pos)

		print("Hit:", target.name)
		print(distance)

		if target.has_method("take_damage"):
			target.take_damage(10)
