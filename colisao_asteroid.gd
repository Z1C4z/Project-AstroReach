extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if (area.get_parent().name  != "Node3D"):
		print("node3d")
	if (area.get_parent().name == "Nave"):
		get_node("/root/Node3D").point -= 1	
		
	print(area.get_parent().name)
			
		

	
	
