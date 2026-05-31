extends MultiMeshInstance3D

@export var terrain : Node3D
@export var amount := 2000

func _ready():

	randomize()

	var mm = MultiMesh.new()
	multimesh = mm

	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = amount

	mm.mesh = preload("res://objects/grass_02/grass.res")

	print(mm.instance_count)

	for i in range(amount):

		var x = randf_range(0, 512)
		var z = randf_range(0, 512)

		var y = terrain.get_data().get_height_at(x, z)

		var transform = Transform3D(
			Basis().scaled(Vector3.ONE * 20.0),
			terrain.global_position + Vector3(x, y - 300, z)
		)

		mm.set_instance_transform(i, transform)

		print(y)
