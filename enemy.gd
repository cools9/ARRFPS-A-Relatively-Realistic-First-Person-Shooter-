extends CharacterBody3D

@export var turn_speed: float = 8.0 # Adjust this in the Inspector to change rotation speed

@onready var raycast = $RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player"
@onready var screams = [
	$"scream 1",
	$Scream2,
	$Scream3
]
var scream_index:=0
var hit_cooldown = 0.0
var hit_cooldown_duration = 1.0

func _ready() -> void:
	raycast.add_exception(self)

func _physics_process(delta: float) -> void:
	distance_from_player()
	
	if not is_on_floor():
		velocity += get_gravity()*5 * delta
	
	# global_position is the Godot 4 shorthand for global_transform.origin
	var current_location = global_position 
	
	# Updated from get_next_location()
	var next_location = nav_agent.get_next_path_position() 
	
	# Fixed spelling from normalised() to normalized()
	var new_velocity = (next_location - current_location).normalized() * 5
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()
	
	# Your distance and direction tracking
	var distance = global_position.distance_to(player.global_position)
	#var direction = (player.global_position - global_position).normalized()
	

	if player and distance > 0.1:
		hit_cooldown -= delta
		# 1. Smoothly rotate the enemy body (Horizontal Y-Axis only)
		var target_pos = player.global_position
		target_pos.y = global_position.y 
		
		var target_transform = transform.looking_at(target_pos, Vector3.UP)
		transform.basis = transform.basis.slerp(target_transform.basis, turn_speed * delta)
		
		raycast.target_position = raycast.to_local(player.global_position)
		raycast.force_raycast_update()
		
		# --- RAYCAST COLLISION/DAMAGE ---
		if raycast.get_collider()==player and hit_cooldown <= 0.0:
			var target = raycast.get_collider()
			var hit_pos = raycast.get_collision_point()
			var distancei = raycast.global_position.distance_to(hit_pos)
			print("Hit:", raycast.get_collider().name)
			#print("Hit:", target.name)
			if target.name == "Player":
				if distancei<=100:
					player.health -= 10
					hit_cooldown=hit_cooldown_duration
			#print(distancei)

func update_target_location(target_location):
	# Updated from set_target_location(). It is now a property, not a function.
	nav_agent.target_position = target_location

func distance_from_player():
	var distance=global_position.distance_to(player.global_position)
	var first_three = str(distance).substr(0, 3)
	$SubViewport/Label.text=str(first_three)
	
	if global_position.y < -100:
		queue_free()

func play_death_scream():
	screams[scream_index].play()
	scream_index = (scream_index + 1) % screams.size()
	print("played")

func die():
	play_death_scream()
	await get_tree().create_timer(4).timeout
	print("killed")
	queue_free()
	
	
