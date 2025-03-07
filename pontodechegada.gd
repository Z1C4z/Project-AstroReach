extends Area3D

func _ready():
	# Conecta o sinal body_entered ao método on_body_entered
	connect("body_entered", Callable(self, "on_body_entered"))

func on_body_entered(body: Node):
	# Verifica se o objeto que entrou na área é o círculo
	if body.name == "Circulo":  # Substitua "Circulo" pelo nome do nó do círculo
		print("Círculo alcançou o ponto final!")
		finalizar_jogo()

func finalizar_jogo():
	print("Jogo finalizado!")
	# Adicione aqui a lógica para finalizar o jogo
