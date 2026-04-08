extends GameUtilities

@export var json_path : String = "res://Minigames/QuizzTime/Assets/questions.json"
@export var score_max : int = 10
var questions : Array = []

@onready var answerContainer = $UI/GridContainer
@onready var answerPanels : Array[Panel] = [
	$UI/GridContainer/Answer1, $UI/GridContainer/Answer4,
	$UI/GridContainer/Answer2, $UI/GridContainer/Answer5,
	$UI/GridContainer/Answer3, $UI/GridContainer/Answer6]
@onready var question_label = $UI/QuestionLabel
@onready var question_image = $UI/PanelContainer/Picture

@onready var respond_timer = $RespondTimer
@onready var reveal_timer = $RevealTimer
@onready var timer_bar = $UI/TimerBar

var shader_gray = ShaderMaterial.new()

enum GameState { START, RESPOND, REVEAL }
var state : GameState
var current_question : Dictionary
var n_answer : int
var answer_right : int
var p1 = QuizTimePlayer.new()
var p2 = QuizTimePlayer.new()

func load_json() -> void:
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("JSON file does not exist at ", json_path)
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			questions = data_received
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_path, " at line ", json.get_error_line())

func _ready() -> void:
	# Appelle la fonciton _ready() de GameUtilities, cette ligne est tres importante
	super()
	p1.setup("1", $UI, score_max)
	p2.setup("2", $UI, score_max)

	question_label.hide()
	question_image.hide()

	load_json()
	if questions.size() < 1:
		end_game_early.emit()
	shader_gray.shader = load("res://Minigames/QuizzTime/Assets/grayscale.gdshader")

	state = GameState.START

func _process(delta: float) -> void:
	# Appelle la fonction _process(delta) de GameUtilities, cette ligne est très importante
	super(delta)
	
	if game_started:
		# Votre boucle de jeu
		# Mettez votre logique de jeu ici !
		match state:
			GameState.START:
				start_new_round()
				question_label.show()
				question_image.show()
			GameState.RESPOND:
				timer_bar.value = respond_timer.time_left / respond_timer.wait_time
				check_buttons()
				check_answers()
			GameState.REVEAL:
				timer_bar.value = 1 - reveal_timer.time_left / reveal_timer.wait_time

func get_winner() -> bool:
	if p1.score == p2.score:
		if p1.time_score == p2.time_score:
			return randf() > .5
		return p1.time_score > p2.time_score
	return p1.score > p2.score

func start_new_round() -> void:
	set_new_question()
	state = GameState.RESPOND
	respond_timer.start()
	p1.answer = -1
	p2.answer = -1
	
	for el in [p1.cursor, p2.cursor, p1.cursor_bp]:
		hide_cursor(el)
	for i in range(n_answer):
		answerPanels[i].material = null

func set_new_question() -> void:
	current_question = questions.pop_at(randi() % questions.size())
	question_label.text = current_question["question"]
	var answers : Array = current_question["miss"]
	if answers.size() >= 5:
		n_answer = 6
		answerContainer.columns = 3
		answerPanels[4].show()
		answerPanels[5].show()
	else:
		n_answer = 4
		answerContainer.columns = 2
		answerPanels[4].hide()
		answerPanels[5].hide()

	answers.shuffle()
	answers = answers.slice(0, n_answer - 1)
	answers.push_back(current_question["answer"])
	answers.shuffle()
	answer_right = answers.find(current_question["answer"])
	
	for i in range(n_answer):
		answerPanels[i].get_child(0).text = answers[i]
	var image = Image.load_from_file(current_question["picture"])
	question_image.texture = ImageTexture.create_from_image(image)

func check_buttons() -> void:
	for i in range(n_answer):
		if p1.answer == -1 and Input.is_action_just_pressed(p1.inputs[i]):
			p1.answer = i
			if p1.answer == p2.answer:
				hide_cursor(p2.cursor)
				show_cursor(p2.cursor_bp, i)
			else:
				show_cursor(p1.cursor, i)
		if p2.answer == -1 and Input.is_action_just_pressed(p2.inputs[i]):
			p2.answer = i
			if p1.answer == p2.answer:
				hide_cursor(p1.cursor)
				show_cursor(p1.cursor_bp, i)
			else:
				show_cursor(p2.cursor, i)

func check_answers() -> void:
	if p1.answer == answer_right and p2.answer == answer_right:
		print("Too fast! Both answered at the same time")
		finish_round(null)
	elif p1.answer == answer_right:
		print("P1 won the round!")
		finish_round(p1)
	elif p2.answer == answer_right:
		print("P2 won the round!")
		finish_round(p2)
	elif p1.answer != -1 and p2.answer != -1:
		print("Both players lost!")
		finish_round(null)

func finish_round(winner: QuizTimePlayer) -> void:
	respond_timer.stop()
	if winner != null:
		winner.score += 1
		winner.time_score += respond_timer.time_left
		$UI/AnimationPlayer.play("P" + winner.i + "_win")
		winner.scorebar.value = winner.score

	state = GameState.REVEAL
	for i in range(n_answer):
		if i != answer_right:
			answerPanels[i].material = shader_gray
	
	reveal_timer.start()

func _on_respond_timer_timeout() -> void:
	finish_round(null)

func _on_reveal_timer_timeout() -> void:
	if questions.size() < 1 or p1.score >= score_max or p2.score >= score_max or timer_jeu.time_left < 5:
		end_game.emit(get_winner())
	else:
		start_new_round()
	
func hide_cursor(cursor: NinePatchRect) -> void:
	cursor.hide()
	cursor.reparent(self)

func show_cursor(cursor: NinePatchRect, pos: int) -> void:
	if pos >= n_answer:
		return
	cursor.show()
	cursor.reparent(answerPanels[pos])
	cursor.position = Vector2(-6, -6)
	cursor.size = Vector2(282 if n_answer == 6 else 420, 112)

#TODO faire un reveal pour les quel est ce pokémon
#TODO pool de 