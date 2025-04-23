extends Node3D

var circulo = {
	"vermelho": "res://images/image_barra/errado.png",
	"verde": "res://images/image_barra/certo.png",
}

@onready var fase_status = {
	1: {"status": "null", "local": $player/UI/Left_eye_control/circulo1},
	2: {"status": "null", "local": $player/UI/Left_eye_control/circulo2},
	3: {"status": "null", "local": $player/UI/Left_eye_control/circulo3},
	4: {"status": "null", "local": $player/UI/Left_eye_control/circulo4},
	5: {"status": "null", "local": $player/UI/Left_eye_control/circulo5}
}

@onready var sprites = {
	1: $"player/UI/Left_eye_control/HBoxContainer/Life-1",
	2: $"player/UI/Left_eye_control/HBoxContainer/Life-2",
	3: $"player/UI/Left_eye_control/HBoxContainer/Life-3"
}

@onready var timer_sprite = $player/UI/Right_eye_control/Timer
@onready var score_sprite = $player/UI/Right_eye_control/Score
@onready var my_timer = $Timer
@onready var defeatsprite = $player/SubViewport/GyroCam/Spritederrota

var last_second = "0"
var game = true
var oxygen = 3
var score = 0
var point = 0
var current_stage = 1
var timer_connected = false

func _ready():
	esconderteladerrota()

func _process(delta: float):
	if point != 0:
		var passou = point > 0
		update_stage(passou)
		change_score(point)
		point = 0

	if game and my_timer.time_left > 0:
		var new_second = "%10.0f" % my_timer.time_left
		if last_second != new_second:
			last_second = new_second
			timer_sprite.text = "Timer: %s" % new_second

func update_stage(passed: bool):
	if not game:
		return

	if passed:
		if fase_status[current_stage]["status"] != "verde":
			fase_status[current_stage]["local"].texture = load(circulo["verde"])
			fase_status[current_stage]["status"] = "verde"

		if current_stage < 5:
			current_stage += 1
	else:
		# Sempre tira vida ao errar, mesmo na primeira tentativa
		oxygen -= 1
		oxygen = clamp(oxygen, 0, 3)
		update_life_sprites()

		fase_status[current_stage]["local"].texture = load(circulo["vermelho"])
		fase_status[current_stage]["status"] = "vermelho"

		if oxygen <= 0:
			game_over()
			chamarteladerrota()

func update_life_sprites():
	sprites[1].visible = oxygen >= 1
	sprites[2].visible = oxygen >= 2
	sprites[3].visible = oxygen >= 3

func game_over():
	game = false
	print("Game Over!")

func _on_timer_timeout():
	timer_sprite.text = "Timer: Stop"
	my_timer.stop()
	update_stage(false)

func timer(seconds):
	if not timer_connected:
		my_timer.timeout.connect(_on_timer_timeout)
		timer_connected = true
	my_timer.wait_time = seconds
	my_timer.start()

func change_score(p):
	score += p
	score = clamp(score, 0, 5)
	if score_sprite:
		score_sprite.text = "Score: %s" % score

func esconderteladerrota():
	defeatsprite.visible = false

func chamarteladerrota():
	defeatsprite.visible = true
