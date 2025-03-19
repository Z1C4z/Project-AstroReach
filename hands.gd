extends Node2D

var udp = PacketPeerUDP.new()
var listening_port = 5005
var hands = {}
var left_handpose = "unknow"
var right_handpose = "unknow"
var arrastando = false
var velocidade = 1.5  # Velocidade fixa do objeto
var mao_selecionada = null  # Armazena qual mão está controlando o objeto
var camera_rotation_speed = 0.005  # Velocidade de rotação da câmera

var connections = [
	[0,1], [1,2], [2,3], [3,4],         # Polegar
	[0,5], [5,6], [6,7], [7,8],         # Indicador
	[0,9], [9,10], [10,11], [11,12],     # Médio
	[0,13], [13,14], [14,15], [15,16],   # Anelar
	[0,17], [17,18], [18,19], [19,20]    # Mínimo
]

@onready var camera_3d = get_node_or_null("/root/Node3D/player/SubViewport/GyroCam")
@onready var redoma = get_node_or_null("res://Object 3D/root_scene.tscn")
@onready var box2_area = get_node_or_null("/root/Node3D/box2/Area3D")
@onready var boxfinish_area = get_node_or_null("/root/Node3D/boxfinish/Area3D")
@onready var redoma_area: Node3D = $"../../../../RedomaArea3D"
# Referência para a nave
@onready var nave: Node3D  # Ajuste o caminho conforme necessário

func _ready():
	if udp.bind(listening_port) != OK:
		push_error("Falha ao vincular à porta UDP")
		return
	print("Aguardando dados da mão...")

	if box2_area and boxfinish_area:
		boxfinish_area.connect("area_entered", _on_boxfinish_collided)
	
	

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

	# Verifica se uma mão está sobre a nave antes de permitir o movimento
	if camera_3d and nave != null:
		var mao_sobre_nave = detectar_mao_no_objeto(nave, camera_3d)
		
		if mao_sobre_nave:
			# Se a mão está sobre a nave e fechada, começa o arrasto

			if (mao_sobre_nave == "Right" and right_handpose == "close") or \
			   (mao_sobre_nave == "Left" and left_handpose == "close"):
				if not arrastando:
					print("Arrastando a nave com:", mao_sobre_nave)
					arrastando = true
					mao_selecionada = mao_sobre_nave
				  # Define a mão que está controlando a nave
				arrastar_objeto(nave)
		else:
			arrastando = false
			mao_selecionada = null  # Reseta a mão controladora

	# Controle da câmera com setas do teclado
	if camera_3d:
		if Input.is_action_pressed("ui_left"):
			camera_3d.rotation_degrees.y += camera_rotation_speed * 100
		if Input.is_action_pressed("ui_right"):
			camera_3d.rotation_degrees.y -= camera_rotation_speed * 100
		if Input.is_action_pressed("ui_up"):
			camera_3d.rotation_degrees.x += camera_rotation_speed * 100
		if Input.is_action_pressed("ui_down"):
			camera_3d.rotation_degrees.x -= camera_rotation_speed * 100

	# Aqui, você adiciona a rotação no eixo Z
	if InputMap.has_action("ui_rotate_z") and Input.is_action_pressed("ui_rotate_z"):
		camera_3d.rotation_degrees.z += camera_rotation_speed * 100


	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()
		var json = JSON.new()
		var error = json.parse(message)

		if error == OK:
			process_hand_data(json.data)
		else:
			push_error("Erro ao analisar JSON: ", json.get_error_message())
			

func _on_boxfinish_collided(area):
	if area == box2_area:
		print("O box2 chegou ao destino!")

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
	
	if object_3d:  # Verifica se o objeto é a nave
		var screen_pos = world_to_screen(object_3d, camera)
		var hitbox_radius = 100  # Ajuste o raio da hitbox conforme necessário

		for hand_name in hands.keys():
			var hand = hands[hand_name]
			for point in hand:
				if point.distance_to(screen_pos) <= hitbox_radius:
					return hand_name  # Retorna "Right" ou "Left" se a mão estiver na hitbox
	
	return ""  # Nenhuma mão está sobre a nave

func world_to_screen(object_3d: Node3D, camera: Camera3D) -> Vector2:
	if camera:
		return camera.unproject_position(object_3d.global_transform.origin)
	return Vector2.ZERO

func arrastar_objeto(obj: Node3D):
	if obj == nave:  # Apenas arrasta a nave
		if mao_selecionada and hands.has(mao_selecionada) and hands[mao_selecionada].size() > 13:
			var dedo_anelar = hands[mao_selecionada][13]
			var screen_pos = Vector2(dedo_anelar.x, dedo_anelar.y)

			# Projeta a posição da mão no mundo 3D
			var ray_origin = camera_3d.project_ray_origin(screen_pos)
			var ray_dir = camera_3d.project_ray_normal(screen_pos)

			# Mantém a distância fixa entre a nave e a câmera
			var distancia_fixa = obj.global_transform.origin.distance_to(camera_3d.global_transform.origin)
			if distancia_fixa != 6:
				distancia_fixa = 6
			var target_position = ray_origin + (ray_dir.normalized() * distancia_fixa)
			
			# Interpolação para suavizar o movimento
			var velocidade_real = velocidade * 0.1
			var nova_posicao = obj.global_transform.origin.lerp(target_position, velocidade_real)

			# Aplica a nova posição
			obj.global_transform.origin = nova_posicao

			# Debug: Exibe informações de posição e distância
			print("Escala:", obj.scale, " | Posição:", obj.position , " | Distância da câmera:", camera_3d.global_transform.origin.distance_to(obj.global_transform.origin))
