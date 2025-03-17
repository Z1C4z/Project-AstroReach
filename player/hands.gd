extends Node2D

var udp = PacketPeerUDP.new()
var listening_port = 5005
var current_hands = {}  # Stores interpolated positions
var target_hands = {}   # Stores latest received positions
var left_handpose = "unknow"
var right_handpose = "unknow"
var arrastando = false
var velocidade = 1.5
var mao_selecionada = null

var connections = [
	[0,1], [1,2], [2,3], [3,4],
	[0,5], [5,6], [6,7], [7,8],
	[0,9], [9,10], [10,11], [11,12],
	[0,13], [13,14], [14,15], [15,16],
	[0,17], [17,18], [18,19], [19,20]
]

@onready var camera_3d = get_node_or_null("/root/Node3D/player/SubViewport/GyroCam")
@onready var objetos_3d = []
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

func _process(delta):
	# Process UDP packets
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()
		var json = JSON.new()
		var error = json.parse(message)
		
		if error == OK:
			process_hand_data(json.data)
		else:
			push_error("Erro ao analisar JSON: ", json.get_error_message())
	
	# Smooth hand positions
	interpolate_hands(delta)
	
	# Handle 3D sprite interactions
	if camera_3d and sprite_3d:
		for spt in sprite_3d:
			if is_instance_valid(spt):
				var mao_sobre_objeto = detectar_mao_no_objeto(spt, camera_3d)
				if mao_sobre_objeto:
					if (mao_sobre_objeto == "Right" and right_handpose == "pointer") or \
					   (mao_sobre_objeto == "Left" and left_handpose == "pointer"):
						spt.iniciar_carregamento()
					else:
						spt.cancelar_carregamento()
				else:
					spt.cancelar_carregamento()
			else:
				sprite_3d.erase(spt)
	
	# Handle 3D object dragging
	if camera_3d and objetos_3d:
		for obj in objetos_3d:
			var mao_sobre_objeto = detectar_mao_no_objeto(obj, camera_3d)
			if mao_sobre_objeto:
				if (mao_sobre_objeto == "Right" and right_handpose == "close") or \
				   (mao_sobre_objeto == "Left" and left_handpose == "close"):
					if not arrastando:
						arrastando = true
						mao_selecionada = mao_sobre_objeto
					arrastar_objeto(obj)
			else:
				arrastando = false
				mao_selecionada = null
	
	queue_redraw()

func process_hand_data(hand_data):
	target_hands.clear()
	for hand in hand_data.keys():
		var raw_landmarks = hand_data[hand]["landmarks"]
		var screen_landmarks = []
		for lm in raw_landmarks:
			var x = int(lm["x"] * get_viewport().size.x)
			var y = int(lm["y"] * get_viewport().size.y)
			screen_landmarks.append(Vector2(x, y))
		target_hands[hand] = screen_landmarks
	
	left_handpose = hand_data.get("Left", {}).get("pose", "unknow")
	right_handpose = hand_data.get("Right", {}).get("pose", "unknow")

func interpolate_hands(delta):
	# Add new hands and interpolate positions
	for hand in target_hands:
		if not current_hands.has(hand):
			current_hands[hand] = target_hands[hand].duplicate()
		else:
			var curr_hand = current_hands[hand]
			var targ_hand = target_hands[hand]
			for i in range(targ_hand.size()):
				curr_hand[i] = curr_hand[i].lerp(targ_hand[i], delta * 5)  # 5 = 1/0.2
	
	# Remove disappeared hands
	for hand in current_hands.keys():
		if not target_hands.has(hand):
			current_hands.erase(hand)


func _draw():
	for hand in current_hands.values():
		if hand.size() < 21:
			continue
		
		# Draw palm as a filled polygon
		var palm_points = [
			hand[0], hand[5], hand[9], hand[13], hand[17]
		]
		draw_colored_polygon(palm_points, Color(1, 1, 1))  # White palm
		draw_polyline(palm_points + [palm_points[0]], Color(0, 0, 0), 5)  # Black outline
		
		# Draw fingers with black outline
		for conn in connections:
			if conn[0] < hand.size() and conn[1] < hand.size():
				var p1 = hand[conn[0]]
				var p2 = hand[conn[1]]

				# Outline first
				draw_line(p1, p2, Color(0, 0, 0), 10)
				# White inner part
				draw_line(p1, p2, Color(1, 1, 1), 8)

		# Draw smaller dots for joints and fingertips
		for i in range(hand.size()):
			var point = hand[i]
			var radius = 5 if i in [4, 8, 12, 16, 20] else 3  # Smaller circles

			# Outline
			draw_circle(point, radius + 2, Color(0, 0, 0))
			# White fill
			draw_circle(point, radius, Color(1, 1, 1))


func detectar_mao_no_objeto(object_3d: Node3D, camera: Camera3D) -> String:
	var screen_pos = world_to_screen(object_3d, camera)
	if screen_pos == Vector2.ZERO:
		return ""
	
	var hitbox_radius = 100
	for hand_name in current_hands:
		var hand = current_hands[hand_name]
		for point in hand:
			if point.distance_to(screen_pos) <= hitbox_radius:
				return hand_name
	return ""

func world_to_screen(object_3d: Node3D, camera: Camera3D) -> Vector2:
	if not camera:
		return Vector2.ZERO
	var global_pos = object_3d.global_transform.origin
	if camera.is_position_behind(global_pos):
		return Vector2.ZERO
	return camera.unproject_position(global_pos)

func arrastar_objeto(obj: Node3D):
	if mao_selecionada and current_hands.has(mao_selecionada) and current_hands[mao_selecionada].size() > 13:
		var dedo_anelar = current_hands[mao_selecionada][13]
		var screen_pos = Vector2(dedo_anelar.x, dedo_anelar.y)
		var ray_origin = camera_3d.project_ray_origin(screen_pos)
		var ray_dir = camera_3d.project_ray_normal(screen_pos)
		var distancia_fixa = obj.global_transform.origin.distance_to(camera_3d.global_transform.origin)
		var target_position = ray_origin + (ray_dir * distancia_fixa)
		var velocidade_real = velocidade * 0.1
		obj.global_transform.origin = obj.global_transform.origin.lerp(target_position, velocidade_real)
