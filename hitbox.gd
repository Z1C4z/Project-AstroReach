extends Area3D

func _on_area_entered(area: Area3D) -> void:
	get_parent().get_parent().point += 1
