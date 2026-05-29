extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D
const SPEED = 7
const JUMP_VELOCITY = 6

var sensitivty=0.3
var rotation_x=0
var rotation_y=0

func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * sensitivty
		rotation_x -= event.relative.y * sensitivty
		
		rotation_x=clamp(rotation_x,-90,90)
		rotation_degrees.y=rotation_y
		camera.rotation_degrees.x=rotation_x
