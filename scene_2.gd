extends Node3D

# Mapeamento de texturas para cada status
var circulo = {
	"vermelho": "res://images/image_barra/errado.png",
	"verde": "res://images/image_barra/certo.png",
	"cinza": "res://images/image_barra/estrelatopzera.png"
}

# Estado das fases e as texturas associadas
@onready var fase_status = {
	0: {"status": "null", "local": $player/UI/Left_eye_control/circulo1},
	1: {"status": "null", "local": $player/UI/Left_eye_control/circulo2},
	2: {"status": "null", "local": $player/UI/Left_eye_control/circulo3},
	3: {"status": "null", "local": $player/UI/Left_eye_control/circulo4},
	4: {"status": "null", "local": $player/UI/Left_eye_control/circulo5}
}

var fase_atual_index: int = 0
var score: int = 0
var vida: int = 3

# Referências para UI
@onready var timer_sprite = $player/UI/Right_eye_control/Timer
@onready var score_sprite = $player/UI/Right_eye_control/Score
@onready var life_icons = [
	$player/UI/Left_eye_control/HBoxContainer/Life1,
	$player/UI/Left_eye_control/HBoxContainer/Life2,
	$player/UI/Left_eye_control/HBoxContainer/Life3
]
@onready var my_timer = $Timer

# Função chamada quando o jogo começa
func _ready() -> void:
	update_life_ui()
	atualiza_fase_atual()
	timer(30)

# Atualiza o timer e a pontuação
func update_timer():
	if my_timer.time_left > 0:
		var new_second = "%10.0f" % my_timer.time_left
		timer_sprite.text = "Timer: %s" % new_second

# Função chamada quando o timer chega a zero
func _on_timer_timeout():
	timer_sprite.text = "Timer: Stop"
	my_timer.stop()
	print("Timer terminou!")
	perde_fase()

# Inicia o timer com o tempo em segundos
func timer(seconds):
	my_timer.timeout.connect(_on_timer_timeout)
	my_timer.wait_time = seconds
	my_timer.start()

# Atualiza a interface das vidas
func update_life_ui():
	for i in range(3):
		life_icons[i].visible = i < vida

# Atualiza a indicação da fase atual
func atualiza_fase_atual():
	for i in range(5):
		if i == fase_atual_index:
			fase_status[i]["local"].texture = load(circulo.cinza)

# Ganha uma fase
func ganha_fase():
	if fase_atual_index <= 4:
		fase_status[fase_atual_index]["local"].texture = load(circulo.verde)
		score += 10
		fase_atual_index = min(4, fase_atual_index + 1)
		score_sprite.text = "Score: %s" % score
		atualiza_fase_atual()

# Perde uma fase
func perde_fase():
	fase_status[fase_atual_index]["local"].texture = load(circulo.vermelho)  # Alterar fase atual
	fase_atual_index = max(0, fase_atual_index - 1)  # Diminuir índice sem ir abaixo de 0
	score -= 5
	score = max(0, score)
	score_sprite.text = "Score: %s" % score
	vida -= 1
	vida = max(0, vida)  # Garante que a vida não fique negativa
	update_life_ui()
	atualiza_fase_atual()

# Ganha uma vida
func ganha_vida():
	if vida < 3:
		vida += 1
		update_life_ui()

# Função para processar entradas do teclado (mudar de fase e ganhar vida)
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Z:
				ganha_fase()
			KEY_X:
				perde_fase()
			KEY_C:
				ganha_vida()
