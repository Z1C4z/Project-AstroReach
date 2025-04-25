extends Node3D

@export var asteroid_scene: PackedScene  # Cena do asteroide
@export var terra_scene: PackedScene     # Cena da Terra
@export var nave_scene: PackedScene      # Cena da Nave
@export var redoma: CollisionShape3D     # Área de geração
@export var angulo_visao: float = 140.0  # Ângulo de visão para geração (em graus)
@export var distancia_minima_nave_terra: float = 6.0  # Distância mínima entre a nave e a Terra
@export var distancia_maxima_nave_terra: float = 10.0 # Distância máxima entre a nave e a Terra

var posicoes_geradas: Array[Vector3] = []
var nave_instance: Node3D = null         # Referência da nave
var terra_instance: Node3D = null        # Referência da Terra
var posicoes_objetos: Dictionary = {}    # Dicionário para armazenar posições

var gameStarted = false;

func _ready():
	verificar_redoma()
	gerar_obstaculos(15, 2.0, 10.0, 20.0)  # Usa valores padrão

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			gerar_obstaculos(15, 2.0, 10.0, 20.0)  # Exemplo de personalização
		elif event.keycode == KEY_E:
			remover_itens()
		elif event.keycode == KEY_R:
			gameStarted = false
			get_parent().point = 0
			reiniciar_jogo()

func verificar_redoma():
	if redoma == null:
		redoma = $CollisionShape3D

func gerar_obstaculos(num_obstaculos: int = 3, min_distancia: float = 2.0, distancia_minima_nave_terra: float = distancia_minima_nave_terra, distancia_maxima_nave_terra: float = distancia_maxima_nave_terra):
	verificar_redoma()
	
	var teste = get_node("/root/Node3D/player/SubViewport/GyroCam/Hands")
	
	if redoma == null or asteroid_scene == null:
		return

	var shape = redoma.shape  # Declaração da variável shape
	if shape is CylinderShape3D:
		var raio = shape.radius
		var altura = shape.height * 0.5

		# Limpa as posições geradas antes de criar novos objetos
		posicoes_geradas.clear()
		posicoes_objetos.clear()

		# Gera a Terra
		if terra_instance == null:
			terra_instance = criar_obstaculo_unico(terra_scene, raio, altura, min_distancia)
			if terra_instance:
				terra_instance.add_to_group("obstaculos")
				posicoes_objetos["Terra"] = terra_instance.position

		# Gera a Nave
		if nave_instance == null:
			nave_instance = criar_nave(raio, altura, min_distancia, distancia_minima_nave_terra, distancia_maxima_nave_terra)
			if nave_instance:
				nave_instance.add_to_group("arrastavel")
				nave_instance.add_to_group("nave")
				posicoes_objetos["Nave"] = nave_instance.position
			else:
				print("Falha ao criar a nave, tentando reiniciar o nível...")
				await reiniciar_jogo()
				return  # Encerra essa execução para evitar múltiplos resets

		# Gera os asteroides
		var asteroides: Array[Vector3] = []
		for i in range(num_obstaculos):
			var asteroide = criar_asteroide(raio, altura, min_distancia)
			if asteroide:
				asteroides.append(asteroide.position)
				asteroide.add_to_group("obstaculos")
				add_child(asteroide)

		# Salva a lista de asteroides no dicionário
		posicoes_objetos["Asteroides"] = asteroides

		# Exibe as posições no console (para debug)
	#	print("Posições dos objetos: ", posicoes_objetos)
	teste.load_data(nave_instance)
	print(posicoes_objetos)

func criar_nave(raio: float, altura: float, min_distancia: float, distancia_minima_nave_terra: float, distancia_maxima_nave_terra: float) -> Node3D:
	var tentativa = 0
	var max_tentativas = 500
	var posicao_nave: Vector3

	while tentativa < max_tentativas:
		var angulo = randf_range(-angulo_visao / 2, angulo_visao / 2) * PI / 180.0  # Converte para radianos
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)

		posicao_nave = Vector3(x, y, z)

		# Verifica se a posição é válida e está dentro da distância desejada da Terra
		if posicao_valida(posicao_nave, nave_scene, min_distancia):
			if terra_instance:
				var distancia_nave_terra = posicao_nave.distance_to(terra_instance.position)
				if distancia_nave_terra >= distancia_minima_nave_terra and distancia_nave_terra <= distancia_maxima_nave_terra:
					posicoes_geradas.append(posicao_nave)
					break
		
		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para a nave!")
		return null

	# Criar e configurar a nave
	var nave = nave_scene.instantiate()
	nave.name = "Nave"
	nave.position = posicao_nave
	
	
	
	# Adiciona colisão
	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = calcular_raio(nave_scene)
	nave.add_child(collision)

	add_child(nave)
	
	print(nave.get_path())
	
	return nave

func criar_obstaculo_unico(scene: PackedScene, raio: float, altura: float, min_distancia: float) -> Node3D:
	var nova_posicao: Vector3
	var tentativa = 0
	var max_tentativas = 300

	while tentativa < max_tentativas:
		var angulo = randf_range(-angulo_visao / 2, angulo_visao / 2) * PI / 180.0  # Converte para radianos
		var x = cos(angulo) * raio
		var z = sin(angulo) * raio
		var y = randf_range(-altura * 0.7, altura * 0.7)

		nova_posicao = Vector3(x, y, z)

		if posicao_valida(nova_posicao, scene, min_distancia):
			posicoes_geradas.append(nova_posicao)
			break

		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para o objeto!")
		return null

	var obstaculo = scene.instantiate()
	obstaculo.position = nova_posicao
	add_child(obstaculo)

	if obstaculo is Node3D:
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = calcular_raio(scene)
		collision_shape.shape = sphere_shape
		obstaculo.add_child(collision_shape)

	return obstaculo

func criar_asteroide(raio: float, altura: float, min_distancia: float) -> Node3D:
	var nova_posicao: Vector3
	var tentativa = 0

	while tentativa < 100:
		var angulo = randf_range(0, 360) * PI / 180.0  # Converte para radianos (360 graus)
		nova_posicao = Vector3(
			cos(angulo) * raio,
			randf_range(-altura * 0.7, altura * 0.7),
			sin(angulo) * raio
		)
		
		if posicao_valida(nova_posicao, asteroid_scene, min_distancia):
			posicoes_geradas.append(nova_posicao)
			var asteroide = asteroid_scene.instantiate()
			asteroide.position = nova_posicao
			return asteroide
		tentativa += 1
		
	return null

func posicao_valida(posicao: Vector3, scene: PackedScene, min_distancia: float) -> bool:
	for pos in posicoes_geradas:
		if pos.distance_to(posicao) < min_distancia + calcular_raio(scene):
			return false
	return true

func calcular_raio(scene: PackedScene) -> float:
	var instance = scene.instantiate()
	var raio = instance.scale.length() * 0.5 if instance is Node3D else 0.0
	instance.queue_free()
	return raio

func remover_itens():
	gameStarted = false
	for node in get_tree().get_nodes_in_group("obstaculos"):
		node.queue_free()
	if nave_instance:
		nave_instance.queue_free()
		nave_instance = null
	if terra_instance:
		terra_instance.queue_free()
		terra_instance = null
	posicoes_geradas.clear()
	posicoes_objetos.clear()

func regerar_obstaculos(num_obstaculos: int = 3, min_distancia: float = 2.0, distancia_minima_nave_terra: float = distancia_minima_nave_terra, distancia_maxima_nave_terra: float = distancia_maxima_nave_terra):
	verificar_redoma()
	var teste = get_node("/root/Node3D/player/SubViewport/GyroCam/Hands")
	
	if redoma == null or asteroid_scene == null:
		return

	var shape = redoma.shape  # Declaração da variável shape
	if shape is CylinderShape3D:
		var raio = shape.radius
		var altura = shape.height * 0.5
	
		if terra_instance:
					terra_instance.add_to_group("obstaculos")
					posicoes_objetos["Terra"] = terra_instance.position
		
		if nave_instance:
			nave_instance.add_to_group("arrastavel")
			nave_instance.add_to_group("nave")
			posicoes_objetos["Nave"] = nave_instance.position
		else:
			print("Falha ao criar a nave, tentando reiniciar o nível...")
			await reiniciar_jogo()
			return  # Encerra essa execução para evitar múltiplos resets
		# Gera os asteroides
		var asteroides: Array[Vector3] = []
		for i in range(num_obstaculos):
			var asteroide = criar_asteroide(raio, altura, min_distancia)
			if asteroide:
				asteroides.append(asteroide.position)
				asteroide.add_to_group("obstaculos")
				add_child(asteroide)

func reposicionar_objetos():
	verificar_redoma()
	if redoma == null or not (redoma.shape is CylinderShape3D):
		return

	var raio = redoma.shape.radius
	var altura = redoma.shape.height * 0.5
	posicoes_geradas.clear()

	# 1. Obter referência da câmera (adicione isso no topo do script)
	var camera = get_viewport().get_camera_3d()

	# 2. Reposiciona Terra primeiro
	if terra_instance:
		var tentativas = 0
		while tentativas < 250:
			var angulo = randf_range(-angulo_visao/2, angulo_visao/2) * PI/180.0
			var nova_pos = Vector3(
				cos(angulo) * raio,
				randf_range(-altura*0.7, altura*0.7),
				sin(angulo) * raio
			)
			
			# Verifica todas as restrições
			if (posicao_valida(nova_pos, terra_scene, 2.0) and (camera == null or nova_pos.distance_to(camera.global_position) > 3.0)):
				
				terra_instance.position = nova_pos
				posicoes_geradas.append(nova_pos)
				break
			tentativas += 1

	# 3. Reposiciona Nave com restrições reforçadas
	if nave_instance:
		var sucesso = await reposicionar_nave_com_garantia()
		if sucesso:
			print("Nave reposicionada com sucesso!")
		else:
			print("Não foi possível encontrar posição válida para a nave")

	# 4. Reposiciona Asteroides com verificação completa
	for asteroide in get_tree().get_nodes_in_group("obstaculos"):
		if asteroide != terra_instance:
			var tentativas = 0
			while tentativas < 200:
				var angulo = randf_range(0, 360) * PI/180.0
				var nova_pos = Vector3(
					cos(angulo) * raio,
					randf_range(-altura*0.7, altura*0.7),
					sin(angulo) * raio
				)
				
				# Verifica contra todos os objetos existentes
				var posicao_ok = true
				for pos in posicoes_geradas:
					if nova_pos.distance_to(pos) < 2.0 + calcular_raio(asteroid_scene):
						posicao_ok = false
						break
				
				# Verifica distância da câmera
				if posicao_ok and (camera == null or nova_pos.distance_to(camera.global_position) > 3.0):
					asteroide.position = nova_pos
					posicoes_geradas.append(nova_pos)
					break
				
				tentativas += 1

	# Atualiza dicionário de posições
	atualizar_dicionario_posicoes()

func reposicionar_nave_com_garantia() -> bool:
	# Verificação de segurança inicial
	if redoma == null or nave_instance == null:
		return false

	var raio = redoma.shape.radius
	var altura = redoma.shape.height * 0.5
	var camera = get_viewport().get_camera_3d()
	
	# Configurações de tentativas
	var max_tentativas = 500
	var tentativas_por_frame = 20
	var tentativas = 0
	var spawna_nave = false
	
	# Fase de tentativas
	while !spawna_nave:
		for i in range(tentativas_por_frame):
			tentativas += 1
			
			var angulo = randf_range(-angulo_visao/2, angulo_visao/2) * PI/180.0
			var nova_pos = Vector3(
				cos(angulo) * raio,
				randf_range(-altura*0.7, altura*0.7),
				sin(angulo) * raio
			)
			
			# Verificação das condições
			var pos_valida = posicao_valida(nova_pos, nave_scene, 2.0)
			var dist_camera_ok = (camera == null or nova_pos.distance_to(camera.global_position) > 3.5)
			var dist_terra_ok = true
			
			if terra_instance:
				var dist = nova_pos.distance_to(terra_instance.position)
				dist_terra_ok = (dist >= distancia_minima_nave_terra and dist <= distancia_maxima_nave_terra)
			
			if pos_valida and dist_camera_ok and dist_terra_ok:
				nave_instance.position = nova_pos
				spawna_nave = true	
				return true
		
		await get_tree().process_frame
	
	# Retorna false se não encontrou posição válida após todas as tentativas
	return false
	
func atualizar_dicionario_posicoes():
	posicoes_objetos.clear()
	if terra_instance:
		posicoes_objetos["Terra"] = terra_instance.position
	if nave_instance:
		posicoes_objetos["Nave"] = nave_instance.position
	
	var asteroides_pos = []
	for asteroide in get_tree().get_nodes_in_group("obstaculos"):
		if asteroide != terra_instance:
			asteroides_pos.append(asteroide.position)
	posicoes_objetos["Asteroides"] = asteroides_pos

func reiniciar_jogo():
	await remover_itens()
	# Reseta variáveis de estado
	gameStarted = true
	posicoes_geradas.clear()
	posicoes_objetos.clear()
	nave_instance = null
	terra_instance = null
	await gerar_obstaculos(15, 2.0, 7.0, 15.0)
