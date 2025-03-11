extends MeshInstance3D

var rotation_speed = 0.5
var amplitude = 0.005
var velocidade = 2.0
var time_passed = 0.0

func _process(delta):
	time_passed += delta

	var deslocamento = amplitude * sin(velocidade * time_passed)

	global_transform.origin.y += deslocamento

	# Rotaciona ao redor dos eixos Y e X
	rotate_y(rotation_speed * delta)
