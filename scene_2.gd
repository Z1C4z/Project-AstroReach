extends Node3D
var a = "0"
var modo:int
var ponto:int = 0
var jogo = true
@onready var tela_timer1 = $player/UI/Left_eye_control/Time
@onready var tela_timer2 = $player/UI/Right_eye_control/Time
@onready var tela_pontos1 = $player/UI/Left_eye_control/pontos
@onready var tela_pontos2 = $player/UI/Right_eye_control/pontos
@onready var my_timer = $Timer

func _ready():
	tempo(50)
	
	
	

func _process(delta: float):
	if jogo == true:
		if my_timer.time_left > 0:
			var b = "%10.0f" % my_timer.time_left
			if (a != b):
				a = b
				tela_timer1.text = "Timer:%s"%b
				tela_timer2.text = "Timer:%s"%b
			
			
	

func _on_timer_timeout():
	tela_timer1.text = "Timer: Stop"
	tela_timer2.text = "Timer: Stop"
	my_timer.stop()


	
	
	
func tempo(modo):
	my_timer.timeout.connect(_on_timer_timeout)
	my_timer.wait_time = modo
	my_timer.start()
	
func tempo_pause():
	tela_timer1.text = "Timer: Stop"
	tela_timer2.text = "Timer: Stop"
	my_timer.stop()
	
	
func tempo_resetar():
	my_timer.start()

func add_pontos(pontos):
	ponto+=pontos
	tela_pontos1.text = "Pontos:  %s"%ponto
	tela_pontos2.text = "Pontos:  %s"%ponto

func restard_pontos():
	ponto = 0
	tela_pontos1.text = "Pontos:  0"
	tela_pontos2.text = "Pontos:  0"
	
func menos_pontos(pontos):
	ponto-=pontos
	tela_pontos1.text = "Pontos:  %s"%ponto
	tela_pontos2.text = "Pontos:  %s"%ponto
