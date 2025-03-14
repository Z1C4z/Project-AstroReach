extends Area3D

var carga: MeshInstance3D

@onready var ponto = preload("res://scene_2.gd").new()
func _ready():	
	# Procura pelo nó "carga"
	carga = get_tree().root.find_child("carga", true, false)
	if carga and carga is MeshInstance3D:
		print("MeshInstance3D 'carga' encontrado!")
	else:
		print("MeshInstance3D 'carga' não encontrado.")

func _on_area_entered(area: Area3D) -> void:
	if carga and carga is MeshInstance3D:
		ponto.add_pontos(1)
