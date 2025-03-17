extends Node3D

@export var asteroid_scene: PackedScene  # Cena do asteroide
@export var terra_scene: PackedScene     # Cena da Terra
@export var nave_scene: PackedScene      # Cena da Nave
@export var redoma: CollisionShape3D     # Área de geração
@export var num_obstaculos: int = 15     # Quantidade de asteroides
@export var min_distancia: float = 1.9   # Distância mínima entre objetos

var posicoes_geradas: Array[Vector3] = []
var nave_instance: Node3D = null         # Referência da nave

func _ready():
	verificar_redoma()
	gerar_obstaculos()

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
	
	if redoma == null or asteroid_scene == null:
		return

	var shape = redoma.shape  # Declaração da variável shape
	if shape is CylinderShape3D:
		var raio = shape.radius
		var altura = shape.height * 0.5

		criar_obstaculo_unico(terra_scene, raio, altura)
		criar_nave(raio, altura)
		
		for i in range(num_obstaculos):
			criar_asteroide(raio, altura)

func criar_nave(raio: float, altura: float):
	var tentativa = 0
	var max_tentativas = 100
	var posicao_nave: Vector3

	while tentativa < max_tentativas:
		var angulo = randf() * TAU
		var distancia = randf() * raio  # Garante que fique dentro do raio
		var x = cos(angulo) * distancia
		var z = sin(angulo) * distancia
		var y = randf_range(-altura * 0.7, altura * 0.7)  # Dentro da altura

		posicao_nave = Vector3(x, y, z)

		if posicao_valida(posicao_nave, nave_scene):
			break
		
		tentativa += 1

	if tentativa >= max_tentativas:
		print("Erro: Não foi possível encontrar uma posição válida para a nave!")
		return

	# Criar e configurar a nave
	nave_instance = nave_scene.instantiate()
	nave_instance.name = "Nave"
	nave_instance.position = posicao_nave
	nave_instance.add_to_group("arrastavel")
	nave_instance.add_to_group("nave")
	
	# Adiciona colisão
	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = calcular_raio(nave_scene)
	nave_instance.add_child(collision)

	add_child(nave_instance)


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
	obstaculo.position = nova_posicao
	add_child(obstaculo)
	obstaculo.add_to_group("obstaculos")

	# Adiciona a nave a um grupo específico
	if scene == nave_scene:
		obstaculo.name = "Nave"  # Define um nome único
		obstaculo.add_to_group("nave")  # Adiciona ao grupo "nave"

	if obstaculo is Node3D:
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = calcular_raio(scene)
		collision_shape.shape = sphere_shape
		obstaculo.add_child(collision_shape)

func criar_asteroide(raio: float, altura: float):
	var nova_posicao: Vector3
	var tentativa = 0

	while tentativa < 100:
		var angulo = randf() * TAU
		nova_posicao = Vector3(
			cos(angulo) * raio,
			randf_range(-altura * 0.7, altura * 0.7),
			sin(angulo) * raio
		)
		
		if posicao_valida(nova_posicao, asteroid_scene):
			posicoes_geradas.append(nova_posicao)
			var asteroide = asteroid_scene.instantiate()
			asteroide.position = nova_posicao
			asteroide.add_to_group("obstaculos")
			adicionar_colisao(asteroide, calcular_raio(asteroid_scene))
			add_child(asteroide)
			return
		tentativa += 1

func adicionar_colisao(obj: Node3D, raio: float):
	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = raio
	obj.add_child(collision)

func posicao_valida(posicao: Vector3, scene: PackedScene) -> bool:
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
	for node in get_tree().get_nodes_in_group("obstaculos"):
		node.queue_free()
	if nave_instance:
		nave_instance.queue_free()
	posicoes_geradas.clear()

func reiniciar_jogo():
	remover_itens()
	gerar_obstaculos()
