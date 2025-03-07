extends Area3D

# Variáveis exportáveis para configurar os objetos pelo editor
@export var obstaculo_scenes: Array[PackedScene]  # Lista de cenas de planetas
@export var redoma: CollisionShape3D  # Área de colisão para definir o espaço disponível
@export var num_obstaculos: int = 10  # Número de planetas gerados (excluindo Terra e Nave)
@export var min_distancia: float = 1.5  # Distância mínima entre planetas

@export var terra_scene: PackedScene  # Cena representando a Terra
@export var nave_scene: PackedScene  # Cena representando a Nave

var posicoes_geradas: Array[Vector3]  # Lista de posições já utilizadas

func _ready():
	# Garante que a redoma está definida
	if redoma == null:
		redoma = $CollisionShape3D
	gerar_obstaculos()

func gerar_obstaculos():
	# Verifica se a redoma está definida
	if redoma == null:
		print("Erro: Redoma não está definida!")
		return

	# Verifica se há planetas na lista
	if obstaculo_scenes.is_empty():
		print("Erro: Nenhum planeta foi adicionado à lista!")
		return

	var shape = redoma.shape
	if shape is CylinderShape3D:
		var raio = shape.radius  # Raio da área de geração
		var altura = shape.height * 0.5  # Metade da altura do cilindro

		# Criação da Terra
		if terra_scene:
			criar_obstaculo_unico(terra_scene, raio, altura)

		# Criação da Nave
		if nave_scene:
			criar_obstaculo_unico(nave_scene, raio, altura)

		# Criação dos demais planetas
		for i in range(num_obstaculos):  
			criar_obstaculo_aleatorio(raio, altura)

func criar_obstaculo_unico(scene: PackedScene, raio: float, altura: float):
	var nova_posicao: Vector3
	var tentativa = 0
	var max_tentativas = 10

	# Tenta encontrar uma posição válida sem sobreposição
	while tentativa < max_tentativas:
		var angulo = randf() * TAU  # Gera um ângulo aleatório
		var x = cos(angulo) * raio  # Calcula a posição X
		var z = sin(angulo) * raio  # Calcula a posição Z
		var y = randf_range(-altura * 0.7, altura * 0.7)  # Define uma altura aleatória

		nova_posicao = Vector3(x, y, z)

		# Verifica se a posição está muito próxima de outras
		var muito_perto = false
		for pos in posicoes_geradas:
			if pos.distance_to(nova_posicao) < min_distancia:
				muito_perto = true
				break

		if not muito_perto:
			posicoes_geradas.append(nova_posicao)
			break  # Sai do loop se encontrou uma posição válida

		tentativa += 1

	# Instancia e posiciona o objeto
	var obstaculo = scene.instantiate()
	obstaculo.position = nova_posicao
	add_child(obstaculo)

func criar_obstaculo_aleatorio(raio: float, altura: float):
	if obstaculo_scenes.is_empty():
		return

	var nova_posicao: Vector3
	var tentativa = 0
	var max_tentativas = 10

	# Encontra uma posição válida para o planeta
	while tentativa < max_tentativas:
		var angulo = randf() * TAU
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)

		nova_posicao = Vector3(x, y, z)

		var muito_perto = false
		for pos in posicoes_geradas:
			if pos.distance_to(nova_posicao) < min_distancia:
				muito_perto = true
				break

		if not muito_perto:
			posicoes_geradas.append(nova_posicao)
			break  

		tentativa += 1

	# Escolhe um planeta aleatório da lista e instancia na posição gerada
	var random_scene = obstaculo_scenes.pick_random()
	var obstaculo = random_scene.instantiate()
	obstaculo.position = nova_posicao
	add_child(obstaculo)
