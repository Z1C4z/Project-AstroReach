extends Node3D

@export var asteroid_scene: PackedScene  # Única cena de asteroide
@export var terra_scene: PackedScene  # Cena da Terra
@export var nave_scene: PackedScene  # Cena da Nave
@export var redoma: CollisionShape3D  # Área onde os planetas serão gerados
@export var num_obstaculos: int = 15  # Número de planetas a serem gerados
@export var min_distancia: float = 1.9  # Distância mínima entre os planetas

var posicoes_geradas: Array[Vector3] = []  # Armazena as posições já usadas

func _ready():
	verificar_redoma()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			gerar_obstaculos()
		elif event.keycode == KEY_E:
			remover_itens()
		elif event.keycode == KEY_R:
			reiniciar_jogo()

func verificar_redoma():
	if redoma == null:
		redoma = $CollisionShape3D

func gerar_obstaculos():
	verificar_redoma()

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
	var max_tentativas = 100

	while tentativa < max_tentativas:
		var angulo = randf() * TAU
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)

		nova_posicao = Vector3(x, y, z)

		if posicao_valida(nova_posicao, scene):
			posicoes_geradas.append(nova_posicao)
			break

		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para o objeto!")
		return

	var obstaculo = scene.instantiate()
	obstaculo.add_to_group("obstaculos")  # Adiciona ao grupo
	obstaculo.position = nova_posicao
	add_child(obstaculo)

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

	var asteroide = asteroid_scene.instantiate()
	asteroide.add_to_group("obstaculos")  # Adiciona ao grupo
	asteroide.position = nova_posicao
	add_child(asteroide)

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
	var raio = 0.0
	if instance is Node3D:
		var scale = instance.scale
		raio = max(scale.x, scale.y, scale.z) * 0.5
	instance.queue_free()  # Libera a instância temporária
	return raio

func remover_itens():
	# Remove todos os obstáculos pelo grupo
	for node in get_tree().get_nodes_in_group("obstaculos"):
		node.queue_free()
	
	# Limpa as posições geradas
	posicoes_geradas.clear()
	
	# Garante que a redoma ainda esteja presente
	verificar_redoma()

func reiniciar_jogo():
	remover_itens()
	verificar_redoma()
	gerar_obstaculos()
