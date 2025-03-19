extends Node3D
var  circulo = {"laranja":"res://images/image_barra/semi_errado.png","vermelho":"res://images/image_barra/errado.png","verde":"res://images/image_barra/certo.png"}
@onready var  fase_status = {1:{"status":"null","local":$player/UI/Left_eye_control/circulo1},2:{"status":"null","local":$player/UI/Left_eye_control/circulo2},3:{"status":"null","local":$player/UI/Left_eye_control/circulo3},4:{"status":"null","local":$player/UI/Left_eye_control/circulo4},5:{"status":"null","local":$player/UI/Left_eye_control/circulo5}}
@onready var imagem  
var fase_atual
var fase:int = 0
var ultima_fase:int= 0
# Variáveis globais
var last_second = "0"  # Armazena o último segundo exibido no timer
var game = true        # Controla se o jogo está ativo ou não
var oxygen = 3         # Quantidade de oxigênio do jogador
var life = 3           # Quantidade de vidas (redundante com `oxygen`, pode ser removida)
var score = 0          # Pontuação do jogador
var point = 0          # Pontos temporários a serem adicionados à pontuação

# Referências aos sprites de oxigênio (vidas) na interface
@onready var sprites = {
	1: $"player/UI/Left_eye_control/HBoxContainer/Life-1",
	2: $"player/UI/Left_eye_control/HBoxContainer/Life-2",
	3: $"player/UI/Left_eye_control/HBoxContainer/Life-3"
}
var visibility: bool  # Controla a visibilidade dos sprites de oxigênio
@onready var lost_oxygen  # Referência ao sprite de oxigênio que será alterado
@onready var timer_sprite = $player/UI/Right_eye_control/Timer  # Referência ao texto do timer
@onready var score_sprite = $player/UI/Right_eye_control/Score  # Referência ao texto da pontuação
@onready var my_timer = $Timer  # Referência ao timer

func _process(delta: float):
	
	if fase != ultima_fase:
		imagem = fase_status[fase].local
		if fase >ultima_fase:
			fase_atual = fase_status[fase]
			if fase_atual.status == "vermelho":
				imagem.texture =load(circulo.laranja)
				fase_status[fase].status = "laranja"
			elif fase_atual.status == "null":
				imagem.texture = load(circulo.verde)
				fase_status[fase].status = "verde"
			else:
				imagem.texture = circulo[fase_atual.status]
			ultima_fase = fase
				
		else:
			fase_atual = fase_status[fase]
			if fase_atual.status == "verde":
				imagem.texture = load(circulo.laranja)
				fase_status[fase].status = "laranja"
			elif fase_atual.stautus == "null":
				imagem.texture = load(circulo.vermelho)
				fase_status[fase].status = "vermelho"
			else:
				imagem.texture = load(circulo[fase_atual.status])
				
			ultima_fase = 0
			fase = 0
		# Verifica se o oxigênio foi alterado
		if oxygen != life:
			# Define a visibilidade do sprite de oxigênio perdido/ganho
			if life > oxygen:
				visibility = false  # Esconde o sprite se o oxigênio diminuiu
			else:
				visibility = true   # Mostra o sprite se o oxigênio aumentou
			lost_oxygen = sprites[life]  # Obtém o sprite correspondente à vida atual
			lost_oxygen.visible = visibility  # Atualiza a visibilidade do sprite
			life = oxygen  # Sincroniza `life` com `oxygen`

	# Atualiza o timer na tela
	if game == true:
		if my_timer.time_left > 0:
			var new_second = "%10.0f" % my_timer.time_left  # Formata o tempo restante
			if last_second != new_second:  # Verifica se o segundo mudou
				last_second = new_second  # Atualiza o último segundo exibido
				timer_sprite.text = "Timer: %s" % new_second  # Atualiza o texto do timer

	# Atualiza a pontuação
	if point != 0:
		change_score(point)  # Adiciona os pontos à pontuação
		score = 0  # Reseta os pontos temporários

func _on_timer_timeout():
	# Chamado quando o timer chega a zero
	timer_sprite.text = "Timer: Stop"  # Atualiza o texto do timer
	my_timer.stop()  # Para o timer
	change_oxygen(-1)  # Reduz o oxigênio

func timer(seconds):
	# Configura e inicia o timer
	my_timer.timeout.connect(_on_timer_timeout)  # Conecta o sinal de timeout à função
	my_timer.wait_time = seconds  # Define o tempo do timer
	my_timer.start()
  # Inicia o timer

func change_score(point):
	# Adiciona pontos à pontuação
	score += point
	if score_sprite:
		score_sprite.text = "Score: %s" % score  # Atualiza o texto da pontuação

func change_oxygen(value):
	# Altera o valor do oxigênio
	oxygen += value

func add_fase():
	if fase >=5:
		pass 
	else:
		fase+=1

 
func menos_fase():
	if fase ==1:
		pass 
	else:
		fase-=1
