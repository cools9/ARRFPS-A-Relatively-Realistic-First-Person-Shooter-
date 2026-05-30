extends RigidBody3D

@export var speed := 200.0
@export var air_density := 1.225
@export var drag_coefficient := 0.295
@export var area := 0.00005

func _ready() -> void:
	linear_velocity = -transform.basis.z * speed

func _physics_process(delta: float) -> void:
	var v = linear_velocity
	var speed_val = v.length()

	if speed_val == 0:
		return

	var drag_dir = -v.normalized()

	var drag_mag = 0.5 * air_density * drag_coefficient * area * speed_val * speed_val

	var drag_force = drag_dir * drag_mag

	linear_velocity += (drag_force / mass) * delta
