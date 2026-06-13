extends Node3D

@onready var player = $Player

var repath_timer := 0.0

func _physics_process(delta):
	repath_timer -= delta

	if repath_timer <= 0:
		repath_timer = 0.25

		get_tree().call_group(
			"enemies",
			"update_target_location",
			player.global_position
		)
