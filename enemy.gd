extends CharacterBody3D

@export var turn_speed: float = 8.0 # Adjust this in the Inspector to change rotation speed

@onready var raycast = $RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player"
var hit_cooldown = 0.0
var hit_cooldown_duration = 1.0

func _physics_process(delta: float) -> void:
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
	var direction = (player.global_position - global_position).normalized()
	
	# Catch up to the player if they get too far away
	#if distance > 100:
	#	global_position = player.global_position
		
	# --- ROTATION LOGIC ---
	if player and distance > 0.1:
		# 1. Smoothly rotate the enemy body (Horizontal Y-Axis only)
		var target_pos = player.global_position
		target_pos.y = global_position.y 
		
		var target_transform = transform.looking_at(target_pos, Vector3.UP)
		transform.basis = transform.basis.slerp(target_transform.basis, turn_speed * delta)
		
		# 2. Added: Make the RayCast look directly at the player's actual center (includes height!)
		raycast.look_at(player.global_position, Vector3.UP)
		
		# --- RAYCAST COLLISION/DAMAGE ---
		if raycast.is_colliding() and hit_cooldown <= 0.0:
			var target = raycast.get_collider()
			var hit_pos = raycast.get_collision_point()
			var distancei = raycast.global_position.distance_to(hit_pos)
			
			print("Hit:", target.name)
			if target.name == "Player":
				player.health -= 10
				hit_cooldown=hit_cooldown_duration
			print(distancei)

func update_target_location(target_location):
	# Updated from set_target_location(). It is now a property, not a function.
	nav_agent.target_position = target_location
