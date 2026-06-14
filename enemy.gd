extends CharacterBody3D
@export var turn_speed: float = 8.0
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
var has_been_hit=false
func _ready() -> void:
	raycast.add_exception(self)
func _physics_process(delta: float) -> void:
	distance_from_player()
	
	if not is_on_floor():
		velocity += get_gravity()*5 * delta
	
	var current_location = global_position 
	var next_location = nav_agent.get_next_path_position() 
	var new_velocity = (next_location - current_location).normalized() * 5
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()
	
	var distance = global_position.distance_to(player.global_position)
	
	if player and distance > 0.1 and !has_been_hit:
		hit_cooldown -= delta
		var target_pos = player.global_position
		target_pos.y = global_position.y 
		
		var target_transform = transform.looking_at(target_pos, Vector3.UP)
		transform.basis = transform.basis.slerp(target_transform.basis, turn_speed * delta)
		
		if distance <= 100.0:
			raycast.target_position = raycast.to_local(player.global_position + Vector3(0, 1.0, 0))
			raycast.force_raycast_update()
		
		if raycast.get_collider() == player and hit_cooldown <= 0.0:
			if distance <= 100.0:
				player.health -= 5
				player.health_bar_shake()
				hit_cooldown = hit_cooldown_duration

func update_target_location(target_location):
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
	has_been_hit=true
	play_death_scream()
	await get_tree().create_timer(4).timeout
	print("killed")
	queue_free()
