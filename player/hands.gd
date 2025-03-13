extends Node2D

var buttonsScript = preload("res://Scenes/MenuScene/buttons.gd").new()

var udp = PacketPeerUDP.new()
var listening_port = 5005
var hands = {}
var left_handpose = "unknow"
var right_handpose = "unknow"
var arrastando = false
var velocidade = 1.5  # Velocidade fixa do objeto
var mao_selecionada = null  # Armazena qual mão está controlando o objeto

var connections = [
	[0,1], [1,2], [2,3], [3,4],         # Polegar
	[0,5], [5,6], [6,7], [7,8],         # Indicador
	[0,9], [9,10], [10,11], [11,12],     # Médio
	[0,13], [13,14], [14,15], [15,16],   # Anelar
	[0,17], [17,18], [18,19], [19,20]    # Mínimo
]

@onready var camera_3d = get_node_or_null("/root/Node3D/player/SubViewport/GyroCam")
@onready var objetos_3d = []  # Lista para armazenar todos os MeshInstance3D
@onready var sprite_3d = []

func _ready():
	if udp.bind(listening_port) != OK:
		push_error("Falha ao vincular à porta UDP")
		return
	print("Aguardando dados da mão...")

	# Buscar todos os MeshInstance3D na cena
	var root_node = get_tree().get_root().get_node("Node3D")
	if root_node:
		for child in root_node.get_children():
			if child is MeshInstance3D:
				objetos_3d.append(child)
			elif child is Sprite3D:
				sprite_3d.append(child)

func _process(_delta):
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()
		var json = JSON.new()
		var error = json.parse(message)
		
		if error == OK:
			process_hand_data(json.data)
		else:
			push_error("Erro ao analisar JSON: ", json.get_error_message())
	
	if camera_3d and sprite_3d:
		for spt in sprite_3d:
			var a = detectar_mao_no_objeto(spt, camera_3d)
			if a:
				buttonsScript.buttons_function(spt.name)
				
	# Verifica se uma mão está sobre algum objeto antes de permitir o movimento
	if camera_3d and objetos_3d:
		for obj in objetos_3d:
			var mao_sobre_objeto = detectar_mao_no_objeto(obj, camera_3d)

			if mao_sobre_objeto:
				# Se a mão está sobre o objeto e fechada, começa o arrasto
				if (mao_sobre_objeto == "Right" and right_handpose == "close") or \
				   (mao_sobre_objeto == "Left" and left_handpose == "close"):
					if not arrastando:
						arrastando = true
						mao_selecionada = mao_sobre_objeto  # Define a mão que está controlando o objeto
					arrastar_objeto(obj)
			else:
				arrastando = false
				mao_selecionada = null  # Reseta a mão controladora

func process_hand_data(hand_data):
	hands.clear()
	for hand in hand_data.keys():
		var raw_landmarks = hand_data[hand]["landmarks"]
		var screen_landmarks = []
		
		for lm in raw_landmarks:
			var x = int(lm["x"] * get_viewport().size.x)
			var y = int(lm["y"] * get_viewport().size.y)
			screen_landmarks.append(Vector2(x, y))
		
		hands[hand] = screen_landmarks

	# Atualiza poses das mãos
	left_handpose = hand_data.get("Left", {}).get("pose", "unknow")
	right_handpose = hand_data.get("Right", {}).get("pose", "unknow")

	queue_redraw()

func _draw():
	for hand in hands.values():
		# Desenhar conexões entre os pontos
		for conn in connections:
			if conn[0] < hand.size() and conn[1] < hand.size():
				draw_line(hand[conn[0]], hand[conn[1]], Color(1, 1, 1), 3)
		
		# Desenhar os pontos da mão
		for point in hand:
			draw_circle(point, 5, Color(0, 1, 0))

func detectar_mao_no_objeto(object_3d: Node3D, camera: Camera3D) -> String:
	var screen_pos = world_to_screen(object_3d, camera)
	if screen_pos == Vector2.ZERO:
		return ""  # Posição inválida ou atrás da câmera
	
	var hitbox_radius = 100  # Aumente para expandir a hitbox

	for hand_name in hands.keys():
		var hand = hands[hand_name]
		for point in hand:
			if point.distance_to(screen_pos) <= hitbox_radius:
				return hand_name  # Retorna "Right" ou "Left" se a mão estiver na hitbox
	
	return ""  # Nenhuma mão está sobre o objeto
	
func detectar_mao_no_sprite(object_3d: Node3D, camera: Camera3D) -> String:
	var screen_pos = world_to_screen(object_3d, camera)
	if screen_pos == Vector2.ZERO:
		return ""  # Posição inválida ou atrás da câmera
	
	var hitbox_radius = 100  # Aumente para expandir a hitbox

	for hand_name in hands.keys():
		var hand = hands[hand_name]
		for point in hand:
			if point.distance_to(screen_pos) <= hitbox_radius:
				return hand_name  # Retorna "Right" ou "Left" se a mão estiver na hitbox
	
	return ""  # Nenhuma mão está sobre o objeto
func world_to_screen(object_3d: Node3D, camera: Camera3D) -> Vector2:
	if not camera:
		return Vector2.ZERO
	var global_pos = object_3d.global_transform.origin
	if camera.is_position_behind(global_pos):
		return Vector2.ZERO
	return camera.unproject_position(global_pos)

func arrastar_objeto(obj: Node3D):
	# O objeto só segue a mão que está sobre ele
	if mao_selecionada and hands.has(mao_selecionada) and hands[mao_selecionada].size() > 13:
		var dedo_anelar = hands[mao_selecionada][13]
		var screen_pos = Vector2(dedo_anelar.x, dedo_anelar.y)

		# Projeta a posição da mão no mundo 3D
		var ray_origin = camera_3d.project_ray_origin(screen_pos)
		var ray_dir = camera_3d.project_ray_normal(screen_pos)
		var distancia_fixa = obj.global_transform.origin.distance_to(camera_3d.global_transform.origin)

		# Calcula a nova posição mantendo a distância fixa
		var target_position = ray_origin + (ray_dir * distancia_fixa)

		# Ajusta a velocidade para evitar movimento instantâneo
		var velocidade_real = velocidade * 0.1
		obj.global_transform.origin = obj.global_transform.origin.lerp(target_position, velocidade_real)
