extends Node3D
 
var circulo = {
	"vermelho": "res://images/image_barra/errado.png",
	"verde": "res://images/image_barra/certo.png",
}
 
@onready var fase_status = {
	1: {"status": "null", "local": $player/UI/Left_eye_control/circulo1},
	2: {"status": "null", "local": $player/UI/Left_eye_control/circulo2},
	3: {"status": "null", "local": $player/UI/Left_eye_control/circulo3},
	4: {"status": "null", "local": $player/UI/Left_eye_control/circulo4},
	5: {"status": "null", "local": $player/UI/Left_eye_control/circulo5}
}
 
@onready var sprites = {
	1: $"player/UI/Left_eye_control/HBoxContainer/Life-1",
	2: $"player/UI/Left_eye_control/HBoxContainer/Life-2",
	3: $"player/UI/Left_eye_control/HBoxContainer/Life-3"
}
 
@onready var timer_sprite = $player/UI/Right_eye_control/Timer
@onready var score_sprite = $player/UI/Right_eye_control/Score
@onready var my_timer = $Timer
@onready var defeatsprite = $player/SubViewport/Spritederrota
@onready var gyro_cam = $player/SubViewport/GyroCam
@onready var victorysprite = $player/SubViewport/Spritevitoria
 
@onready var barra = get_node_or_null("player/UI/Left_eye_control/conteiner")
@onready var itens = get_node_or_null("player/UI/Right_eye_control/conteiner")
@onready var jogo_tela = get_node_or_null("RedomaArea3D")
 
var game = true
var oxygen = 3
var score = 0
var current_stage = 1
var validacao = 0
var timer_connected = false
 
var visibilidade 
 

func _ready():
	esconderteladerrota()
	esconder_meshes_da_redoma()


	for stage in fase_status:
		fase_status[stage]["local"].texture = null
		fase_status[stage]["status"] = "null"
 
	# Comente ou remova este bloco temporariamente
	# if not is_instance_valid(jogo):
	# 	printerr("Erro ao pré-carregar 'test_scene.tscn'!")
	# 	set_process(false)
	# 	return
	# else:
	# 	print("Cena 'test_scene.tscn' pré-carregada com sucesso!")
 
	# O restante da sua função _ready pode permanecer o mesmo
func _process(delta: float):
	
		
	if validacao != 0:
		var passou = validacao > 0
		var valor = abs(validacao)
		print("Validacao:", validacao, " | Passou:", passou, " | Stage:", current_stage)
 
		if game:
			if passou:
				marcar_acerto()
				score += valor
				if current_stage < 5:
					current_stage += 1
				else:
					game_over_vitoria()
			else:
				marcar_erro()
				oxygen -= 1
				update_life_sprites()
				if oxygen <= 0:
					game_over()
 
		validacao = 0
		update_score_display()
 
func marcar_acerto():
	var current = fase_status[current_stage]
	current["local"].texture = load(circulo["verde"])
	current["status"] = "verde"
	print("Acerto! Marcado na fase", current_stage)
 
func marcar_erro():
	var current = fase_status[current_stage]
	if current["status"] != "vermelho":
		current["local"].texture = load(circulo["vermelho"])
		current["status"] = "vermelho"
	print("Erro! Marcado na fase", current_stage)
 
func update_life_sprites():
	for i in sprites:
		sprites[i].visible = (oxygen >= i)
 
func update_score_display():
	if score_sprite:
		score_sprite.text = "Score: %s" % score
 
func game_over():
	game = false
	print("Game Over!")
	chamarteladerrota()
 
func game_over_vitoria():
	game = false
	print("Você venceu!")
	chamartelavitoria()
 
func _on_timer_timeout():
	timer_sprite.text = "Timer: Stop"
	my_timer.stop()
	validacao = -1	# Considera como erro
 
func timer(seconds):
	if not timer_connected:
		my_timer.timeout.connect(_on_timer_timeout)
		timer_connected = true
	my_timer.wait_time = seconds
	my_timer.start()
 
func add_point(points):
	print("add_point chamado com valor:", points)
	validacao = points
 
func esconderteladerrota():
	defeatsprite.visible = false
 
func chamarteladerrota():
	print("entrou na derrota") #so pra teste ok, pode tirar isso aqui depois
	defeatsprite.global_position = gyro_cam.global_position + gyro_cam.global_transform.basis.z * -2.0
	defeatsprite.look_at(gyro_cam.global_position, Vector3.UP)
	defeatsprite.rotate_y(deg_to_rad(180))
	defeatsprite.visible = true
 
func chamartelavitoria():
	victorysprite.global_position = gyro_cam.global_position + gyro_cam.global_transform.basis.z * -2.0
	victorysprite.look_at(gyro_cam.global_position, Vector3.UP)
	victorysprite.rotate_y(deg_to_rad(180))
	victorysprite.visible = true
 
func visivel():
	jogo_tela = get_node_or_null("RedomaArea3D")
	
	if jogo_tela == null:
		print("Node RedomaArea3D não encontrado!")
		return
	
	print("Filhos de RedomaArea3D:")
	for child in jogo_tela.get_children():
		print(" - ", child.name, " (", child.get_class(), ")")
		
func esconder_meshes_da_redoma():
	var redoma = get_node("RedomaArea3D")
	if redoma:
		for filho in redoma.get_children():
			if filho is MeshInstance3D:
				filho.hide()
			elif filho is Node3D:
				for subfilho in filho.get_children():
					if subfilho is MeshInstance3D:
						subfilho.hide()
						
						
func mostrar_meshes_da_redoma():
	var redoma = get_node("RedomaArea3D")
	if redoma:
		for filho in redoma.get_children():
			if filho is MeshInstance3D:
				filho.show()
			elif filho is Node3D:
				for subfilho in filho.get_children():
					if subfilho is MeshInstance3D:
						subfilho.show()



	
