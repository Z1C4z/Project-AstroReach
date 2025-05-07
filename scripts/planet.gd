extends MeshInstance3D

var speed_rotation = 0.5
var amplitude = 0.005
var speed = 2.0
var past_time = 0.0

func _process(delta):
	past_time += delta

	var displacement = amplitude * sin(speed * past_time)

	global_transform.origin.y += displacement

	# Rotaciona ao redor dos eixos Y e X
	rotate_y(speed_rotation * delta)
