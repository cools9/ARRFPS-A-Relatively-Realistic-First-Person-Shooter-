extends RigidBody3D

@export var muzzle_speed := 200.0

# Air model
@export var sea_level_density := 1.225
@export var drag_coefficient := 0.295
@export var area := 0.00005
@export var wind := Vector3.ZERO


# Spin (for Magnus effect realism)
@export var spin_factor := 0.00002

func _ready() -> void:
	custom_integrator = true
	can_sleep = false
	linear_velocity = -transform.basis.z * muzzle_speed
	gravity_scale = gravity_scale

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var v = state.linear_velocity - wind
	var speed = v.length()

	if speed < 0.001:
		return

	# --- altitude-based air density (cheap exponential model) ---
	var height = global_transform.origin.y
	var air_density = sea_level_density * exp(-height * 0.00012)

	# --- quadratic drag (real model) ---
	var drag_dir = -v / speed
	var drag_force = 0.5 * air_density * drag_coefficient * area * speed * speed * drag_dir

	state.apply_force(drag_force)

	# --- Magnus effect (spin drift / bullet curvature) ---
	var omega = state.angular_velocity
	var magnus = omega.cross(v) * spin_factor
	state.apply_force(magnus)

	# --- tiny stabilization damping (prevents infinite wobble) ---
	state.apply_torque(-omega * 0.02)
