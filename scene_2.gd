extends Node3D
var ultimo_segundo = "0"
var modo:int
var ponto:int = 0
var jogo = true
var coraçao = 3
var vida = 3
var pontos = 0

@onready var  lugar = {1:$player/UI/Left_eye_control/HBoxContainer/Panel/Sprite2D,2:$player/UI/Left_eye_control/HBoxContainer/Panel2/Sprite2D,3:$player/UI/Left_eye_control/HBoxContainer/Panel3/Sprite2D}
var visibilidade:bool 
@onready var mudar_coraçaoes 
@onready var tela_timer1 = $player/UI/Right_eye_control/Time
@onready var tela_pontos1 = $player/UI/Right_eye_control/Pontos
@onready var my_timer = $Timer

func _ready(): 
	tempo(60)

func _process(delta: float):
	if coraçao !=vida:
		if vida > coraçao:
			visibilidade = false
		else:
			visibilidade = true
			mudar_coraçaoes = lugar[vida]
			mudar_coraçaoes.visible =visibilidade
			vida = coraçao

	if jogo == true:
		if my_timer.time_left > 0:
			var segundo_novo= "%10.0f" % my_timer.time_left
			if (ultimo_segundo != segundo_novo):
				ultimo_segundo= segundo_novo
				tela_timer1.text = "Timer:%s"%segundo_novo
	if pontos != 0:
		add_pontos(pontos)
		pontos = 0
		
func _on_timer_timeout():
	tela_timer1.text = "Timer: Stop"
	my_timer.stop()
	menos_coraçao()
	
func tempo(modo):
	my_timer.timeout.connect(_on_timer_timeout)
	my_timer.wait_time = modo
	my_timer.start()

func add_pontos(pontos):
	ponto+= pontos
	print(ponto)
	if tela_pontos1:
		tela_pontos1.text = "Pontos: %s" % ponto
	else:
		print("Erro: tela_pontos1 não foi encontrado ou não é um Label.")
		print(tela_pontos1)


func menos_pontos(pontos):
	ponto-=pontos
	tela_pontos1.text = "Pontos:  %s"%ponto

func menos_coraçao():
	coraçao -=1

func add_coraçao():
	coraçao +=1
