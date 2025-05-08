extends Sprite3D

# Referências
@onready var sub_viewport = $SubViewport
@onready var progress_bar = $SubViewport/Control/TextureProgressBar
@onready var icon_texture_rect = $SubViewport/Control/TextureRect  # Referência ao TextureRect do ícone
@export var visibilidade = load("res://scene2.tscn")

var carregando = false
var tempo_carregamento = 0.0
var tempo_total_carregamento = 2.0  # Tempo total para carregar em segundos

func _ready():
	progress_bar.visible = false  # Esconde a barra inicialmente
	atualizar_icone()

func _process(delta):
	if carregando:
		tempo_carregamento += delta
		atualizar_barra(tempo_carregamento / tempo_total_carregamento)
		
		if tempo_carregamento >= tempo_total_carregamento:
			concluir_carregamento()

func iniciar_carregamento():
	if not carregando:
		carregando = true
		tempo_carregamento = 0.0
		progress_bar.visible = true
		  # Atualiza o ícone com base no nome

func cancelar_carregamento():
	if carregando:
		carregando = false
		progress_bar.visible = false

func atualizar_barra(progresso):
	progress_bar.value = progresso * 100

func concluir_carregamento():
	cancelar_carregamento()
	executar_acao()

func executar_acao():
	print("Carregamento concluído! Executando ação para:", name)
	
	# Executa uma função diferente com base no nome do objeto
	match name:
		"PlayButton":
			play()
			
			# Esconder ExitButton ao iniciar o jogo
			var exit_button = get_parent().get_node_or_null("ExitButton")
			if exit_button:
				exit_button.visible = false
			
			# Instancia o script principal e chama a função visível (se necessário)
			visibilidade = visibilidade.instantiate()
			await visibilidade.visivel()
			
		"ExitButton":
			exit()
		_:
			print("Nome do objeto não reconhecido:", name)
	
	self.queue_free()

func atualizar_icone():
	# Altera o ícone no TextureRect com base no nome do objeto
	match name:
		"PlayButton":
			icon_texture_rect.texture = preload("res://images/buttonIcons/playIcon.png")
		"ExitButton":
			icon_texture_rect.texture = preload("res://images/buttonIcons/exitIcon.png")
		_:
			print("Ícone padrão ou nome não reconhecido:", name)

# Funções específicas para cada objeto
func play():
	get_parent().mostrar_meshes_da_redoma()
	get_parent().visibilidade()
	
		

	# Adicione a lógica específica para o objeto1 aqui

func exit():
	get_tree().quit()

func acao_objeto3():
	print("Executando ação personalizada para objeto3")
	# Adicione a lógica específica para o objeto3 aqui
