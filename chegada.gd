extends Area3D
 
func _ready():
	connect("body_entered", _on_body_entered)
 
func _on_body_entered(body):
	print("Nave encostou no planeta!")
		# Adicione aqui a lógica para o que acontece quando a nave encosta
