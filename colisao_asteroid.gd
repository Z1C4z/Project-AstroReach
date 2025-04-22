extends Area3D


func _on_area_entered(area: Area3D) -> void:
	var request = get_node("/root/Node3D")
	if (area.get_parent().name == "Nave"):
		if request.score > 0:
			request.point -= 1	
		

	
	
