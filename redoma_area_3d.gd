extends Node3D

@export var asteroid_scene: PackedScene  # Única cena de asteroide
@export var terra_scene: PackedScene  # Cena da Terra
@export var nave_scene: PackedScene  # Cena da Nave
@export var redoma: CollisionShape3D  # Área onde os planetas serão gerados
@export var num_obstaculos: int = 15  # Número de planetas a serem gerados
@export var min_distancia: float = 1.9  # Distância mínima entre os planetas

var posicoes_geradas: Array[Vector3] = []  # Armazena as posições já usadas

func _ready():
	if redoma == null:
		redoma = $CollisionShape3D  # Certifique-se de que a redoma está definida
	gerar_obstaculos()

func gerar_obstaculos():
	if redoma == null:
		print("Erro: Redoma não está definida!")
		return

	if asteroid_scene == null:
		print("Erro: Cena do asteroide não foi definida!")
		return

	var shape = redoma.shape
	if shape is CylinderShape3D:
		var raio = shape.radius
		var altura = shape.height * 0.5

		# Gera a Terra
		if terra_scene:
			criar_obstaculo_unico(terra_scene, raio, altura)

		# Gera a Nave
		if nave_scene:
			criar_obstaculo_unico(nave_scene, raio, altura)

		# Gera os outros planetas (asteroides)
		for i in range(num_obstaculos):
			criar_asteroide(raio, altura)

func criar_obstaculo_unico(scene: PackedScene, raio: float, altura: float):
	var nova_posicao: Vector3
	var tentativa = 0
	var max_tentativas = 100  # Número máximo de tentativas para evitar loops infinitos

	while tentativa < max_tentativas:
		# Gera uma posição aleatória dentro da redoma
		var angulo = randf() * TAU  # Ângulo aleatório em radianos
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)  # Altura aleatória

		nova_posicao = Vector3(x, y, z)

		# Verifica se a nova posição está longe o suficiente de outros objetos
		if posicao_valida(nova_posicao, scene):
			posicoes_geradas.append(nova_posicao)
			break

		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para o objeto!")
		return

	# Instancia e posiciona o objeto
	var obstaculo = scene.instantiate()
	obstaculo.position = nova_posicao
	add_child(obstaculo)

	# Adiciona colisão ao objeto
	if obstaculo is Node3D:
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = calcular_raio(scene)
		collision_shape.shape = sphere_shape
		obstaculo.add_child(collision_shape)

func criar_asteroide(raio: float, altura: float):
	var nova_posicao: Vector3
	var tentativa = 0
	var max_tentativas = 100

	while tentativa < max_tentativas:
		var angulo = randf() * TAU
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)

		nova_posicao = Vector3(x, y, z)

		if posicao_valida(nova_posicao, asteroid_scene):
			posicoes_geradas.append(nova_posicao)
			break

		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para o asteroide!")
		return

	# Instancia o asteroide
	var asteroide = asteroid_scene.instantiate()
	asteroide.position = nova_posicao
	add_child(asteroide)

	# Adiciona colisão ao asteroide
	if asteroide is Node3D:
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = calcular_raio(asteroid_scene)
		collision_shape.shape = sphere_shape
		asteroide.add_child(collision_shape)

func posicao_valida(posicao: Vector3, scene: PackedScene) -> bool:
	for pos in posicoes_geradas:
		if pos.distance_to(posicao) < min_distancia + calcular_raio(scene):
			return false
	return true

func calcular_raio(scene: PackedScene) -> float:
	var instance = scene.instantiate()
	if instance is Node3D:
		var scale = instance.scale
		# Supondo que o planeta seja uma esfera, o raio é o maior valor da escala
		return max(scale.x, scale.y, scale.z) * 0.5
	instance.queue_free()
	return 0.0

func reiniciar_jogo():
	# Remove todos os planetas, Terra e Nave
	for child in get_children():
		if child is Node3D:
			child.queue_free()

	# Limpa as posições geradas
	posicoes_geradas.clear()

	# Gera novos planetas, Terra e Nave
	gerar_obstaculos()
