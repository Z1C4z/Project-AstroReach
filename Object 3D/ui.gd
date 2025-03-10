extends CanvasLayer

func _process(delta: float) -> void:
	var memoria_usada = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024  # MB
	
	# Verifica se o Label existe antes de modificar o texto
	if $Label:
		$Label.text = "RAM Usada: %.2f MB" % memoria_usada
