extends Area3D

func _on_area_entered(area: Area3D) -> void:
	var request = get_node("/root/Node3D")
	if area.get_parent().name == "Nave":
		# Um erro ocorreu: reduzir a validacao (pode chegar a valores negativos)
		request.validacao -= 1
