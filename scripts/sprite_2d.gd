extends Sprite2D
var animacao: Tween
var esta_cheio: bool = true
func _ready() -> void:
	
		animacao = get_tree().create_tween()
		animacao.set_loops() 
		animacao.tween_property(self, "scale", Vector2(0.11, 0.11), 0.5).set_trans(Tween.TRANS_SINE)
		animacao.tween_property(self, "scale", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_SINE)
