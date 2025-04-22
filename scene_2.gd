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

var last_second = "0"
var game = true
var oxygen = 3
var life = 3
var score = 0
var point = 0
var previous_score = 0
var current_stage = 1
var errors_count = 0  # Contador de erros

@onready var sprites = {
	1: $"player/UI/Left_eye_control/HBoxContainer/Life-1",
	2: $"player/UI/Left_eye_control/HBoxContainer/Life-2",
	3: $"player/UI/Left_eye_control/HBoxContainer/Life-3"
}

@onready var lost_oxygen
@onready var timer_sprite = $player/UI/Right_eye_control/Timer
@onready var score_sprite = $player/UI/Right_eye_control/Score
@onready var my_timer = $Timer

func _process(delta: float):
	if point != 0:
		update_stage(point > 0)
		change_score(point)
		point = 0

	if oxygen != life:
		life = oxygen
		update_life_sprites()

	if game and my_timer.time_left > 0:
		var new_second = "%10.0f" % my_timer.time_left
		if last_second != new_second:
			last_second = new_second
			timer_sprite.text = "Timer: %s" % new_second

func update_life_sprites():
	# Atualiza os sprites de vida baseado no valor atual de 'life'
	# Primeiro erro: Life-3 desaparece
	# Segundo erro: Life-2 desaparece
	# Terceiro erro: Life-1 desaparece
	sprites[3].visible = (errors_count < 1)
	sprites[2].visible = (errors_count < 2)
	sprites[1].visible = (errors_count < 3)
	
	# Game over quando há 3 erros
	if errors_count >= 3:
		game_over()

func update_stage(passed: bool):
	if passed:
		fase_status[current_stage]["local"].texture = load(circulo["verde"])
		fase_status[current_stage]["status"] = "verde"
	else:
		fase_status[current_stage]["local"].texture = load(circulo["vermelho"])
		fase_status[current_stage]["status"] = "vermelho"
		errors_count += 1
		update_life_sprites()

	# Avança para o próximo estágio
	if current_stage < 5:
		current_stage += 1

func game_over():
	game = false
	# Aqui você pode adicionar qualquer lógica adicional para o game over
	print("Game Over!")
	# Por exemplo, mostrar uma tela de game over, parar o jogo, etc.

func _on_timer_timeout():
	timer_sprite.text = "Timer: Stop"
	my_timer.stop()
	change_oxygen(-1)

func timer(seconds):
	my_timer.timeout.connect(_on_timer_timeout)
	my_timer.wait_time = seconds
	my_timer.start()

func change_score(p):
	score += p
	if score < 0:
		score = 0
	elif score > 5:
		score = 5

	if score_sprite:
		score_sprite.text = "Score: %s" % score

func change_oxygen(value):
	oxygen += value
	oxygen = clamp(oxygen, 0, 3)  # Garante que o oxigênio fique entre 0 e 3

func update_fase_status():
	# Update all stages up to current score with green circles
	for i in range(1, score + 1):
		fase_status[i]["local"].texture = load(circulo["verde"])
		fase_status[i]["status"] = "verde"
	
	# If we lost points, show red in the current stage (score + 1)
	if score < previous_score:
		var current_stage = min(score + 1, 5)
		fase_status[current_stage]["local"].texture = load(circulo["vermelho"])
		fase_status[current_stage]["status"] = "vermelho"
	
	# Clear only stages beyond current score (unless we're at max)
	if score < 5:
		for i in range(score + 1, 6):
			if fase_status[i]["status"] != "vermelho":
				fase_status[i]["local"].texture = null
				fase_status[i]["status"] = "null"
