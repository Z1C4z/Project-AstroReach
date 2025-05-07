extends MeshInstance3D

var rotation_speed = 1.0
var amplitude = 0.005
var velocidade = 2.0
var time_passed = 0.0

@onready var light = $Node3D/carga/OmniLight3D

func _ready():
	if light:
		print("Luz carregada com sucesso!")
		configure_light()
	else:
		print("Erro: Luz não encontrada. Verifique o caminho.")

func configure_light():
	light.energy = 2.0  # Intensidade da luz
	light.range = 3.0   # Alcance da luz
	light.color = Color(1, 1, 0.5)  # Cor da luz (amarelo claro)
	light.shadow_enabled = false  # Desativa sombras

func _process(delta):
	time_passed += delta

	# Oscilação vertical
	var deslocamento = amplitude * sin(velocidade * time_passed)
	global_transform.origin.y += deslocamento

	# Rotaciona ao redor do eixo Y
	rotate_y(rotation_speed * delta)

	# Posiciona a luz ao redor do objeto
	if light:
		light.global_transform.origin = global_transform.origin + Vector3(0, 1, 0)
