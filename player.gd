extends CharacterBody3D
@onready var raycast=$Camera3D/RayCast3D
@onready var camera: Camera3D = $Camera3D
@onready var anim = $Camera3D/AK103/AnimationPlayer
@onready var enemy_thingg= preload("res://scenes/enemy.tscn")
var grapple_target: Vector3
var my_position:Vector3
var grappling=false
var fire_timer = 0.0
const FIRE_RATE = 0.1
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

var health=100
var max_health = 100.0
var max_stamina = 200
var stamina=150
var stamina_regen_timer=0.0

const max_cartridge_capacity=30
var cartridge_capacity = 30
var reloading=false

func _ready() -> void:
	my_position=global_position
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	base_camera_y = camera.position.y
	floor_max_angle = deg_to_rad(45)
	floor_snap_length = 0.4
	call_deferred("spawn_enemies")

func _physics_process(delta: float) -> void:
	$CanvasLayer/cartridge.text = str(cartridge_capacity) + "/30"
	set_coordinates()
	health_check()
	set_health()
	stamina_regen_timer += delta
	if stamina_regen_timer >= 2.0:
		stamina_regen_timer = 0.0
		stamina = min(stamina + 10, max_stamina)
	if global_position.y < -100:
		global_position = Vector3(330, 144, 329)

	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# grapple start
	if Input.is_action_just_pressed("grapple"):
		grapple()

	# shoot
	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0:
		if !reloading:
			shoot()
			fire_timer=FIRE_RATE

	# crouch toggle
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		is_crouching = !is_crouching
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

	if not grappling:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			stamina-=0.01
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
		$Camera3D/AK103/GPUParticles3D.restart()
		$Camera3D/AK103/GPUParticles3D.emitting=true
		var target = raycast.get_collider()
		var hit_pos = raycast.get_collision_point()
		var distance = raycast.global_position.distance_to(hit_pos)
		if target==null:return
		print("Hit:", target.name)
		anim.stop()
		anim.play("recoil")
		var player = AudioStreamPlayer3D.new()
		add_child(player)
		player.stream = preload("res://audio/AK-47 Single Shot Sound Effect - SoundEffectsArchive (192k).mp3")
		player.play()
		player.finished.connect(player.queue_free)
		cartridge_capacity-=1
		
		if cartridge_capacity<=0:
			reload()
		print(distance)
		if target.is_in_group("enemies"):
			target.queue_free()

func grapple():
	if stamina >=30:
		if raycast.is_colliding():
			grapple_target = raycast.get_collision_point()
			var direction = (grapple_target - global_position).normalized()
			velocity = direction * 30
			stamina -= 30
		
func set_health():
	$CanvasLayer/VBoxContainer/health.value=health
	$CanvasLayer/VBoxContainer/stamina.value=stamina


func health_check():
	if health <= 0:
		global_position=my_position
		health=max_health
		
func spawn_enemies():
	for i in 5:
		var their_x = randi_range(50, 150) * (1 if randf() > 0.5 else -1)
		var their_z = randi_range(50, 150) * (1 if randf() > 0.5 else -1)
		var enemy = enemy_thingg.instantiate()
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = Vector3(global_position.x + their_x, global_position.y + 500, global_position.z + their_z)
	

func set_coordinates():
	$CanvasLayer/coordinates.text = "X: %d\nY: %d\nZ: %d" % [global_position.x, global_position.y, global_position.z]

func reload():
	if reloading:
		return
	reloading = true
	anim.play("reload")
	await get_tree().create_timer(1.0).timeout
	cartridge_capacity = max_cartridge_capacity
	
	reloading = false


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "water":
		print("estan en water")
