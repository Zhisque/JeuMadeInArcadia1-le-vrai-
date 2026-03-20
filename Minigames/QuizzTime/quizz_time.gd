extends GameUtilities

@export var json_path : String = "res://Minigames/QuizzTime/Assets/questions.json"
var questions : Array = []

@onready var answerContainer = $UI/GridContainer
@onready var answerPanels : Array[Panel] = [
	$UI/GridContainer/Answer1, $UI/GridContainer/Answer4,
	$UI/GridContainer/Answer2, $UI/GridContainer/Answer5,
	$UI/GridContainer/Answer3, $UI/GridContainer/Answer6]
@onready var question_label = $UI/QuestionLabel
@onready var question_image = $UI/Picture

@onready var respond_timer = $RespondTimer
@onready var reveal_timer = $RevealTimer
@onready var timer_bar = $UI/TimerBar

@onready var scoreboard_p1 = $UI/Score1
@onready var scoreboard_p2 = $UI/Score2

@onready var cursor_p1 = $Cursor9P1
@onready var cursor_p2 = $Cursor9P2
@onready var cursor_bp = $Cursor9BP

const inputs_p1 = ["Bouton HautGauche P1", "Bouton BasGauche P1", "Bouton HautCentre P1", "Bouton BasCentre P1", "Bouton HautDroite P1", "Bouton BasDroite P1"]
const inputs_p2 = ["Bouton HautGauche P2", "Bouton BasGauche P2", "Bouton HautCentre P2", "Bouton BasCentre P2", "Bouton HautDroite P2", "Bouton BasDroite P2"]

enum GameState { START, RESPOND, REVEAL }
var state : GameState
var current_question : Dictionary
var n_answer : int
var answer_right : int
var answer_p1 : int
var answer_p2 : int

var score_p1 : int = 0
var score_p2 : int = 0

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
	
	load_json()
	if questions.size() < 1:
		end_game_early.emit()
	
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
			GameState.RESPOND:
				timer_bar.value = respond_timer.time_left / respond_timer.wait_time
				check_buttons()
				check_answers()
			GameState.REVEAL:
				timer_bar.value = 1 - reveal_timer.time_left / reveal_timer.wait_time
		if Input.is_action_just_pressed("Joystick Haut P1"):
			end_game_early.emit()

# Cette fonction sera appelée à la fin d'une partie pour déterminer qui sera le gagnant
# retourne True si joueur1 as gagné, et retourne False si joueur2 as gagné
func get_winner() -> bool:
	return score_p1 > score_p2

func start_new_round() -> void:
	set_new_question()
	state = GameState.RESPOND
	respond_timer.start()
	answer_p1 = -1
	answer_p2 = -1
	
	for el in [cursor_p1, cursor_p2, cursor_bp]:
		hide_cursor(el)

func set_new_question() -> void:
	#TODO pick random not yet played
	current_question = questions.pick_random()
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
		if answer_p1 == -1 and Input.is_action_just_pressed(inputs_p1[i]):
			answer_p1 = i
			if answer_p1 == answer_p2:
				hide_cursor(cursor_p2)
				show_cursor(cursor_bp, i)
			else:
				show_cursor(cursor_p1, i)
		if answer_p2 == -1 and Input.is_action_just_pressed(inputs_p2[i]):
			answer_p2 = i
			if answer_p1 == answer_p2:
				hide_cursor(cursor_p1)
				show_cursor(cursor_bp, i)
			else:
				show_cursor(cursor_p2, i)

func check_answers() -> void:
	if answer_p1 == answer_right and answer_p2 == answer_right:
		print("Too fast! Both answered at the same time")
		finish_round(0)
	elif answer_p1 == answer_right:
		print("P1 won the round!")
		finish_round(1)
	elif answer_p2 == answer_right:
		print("P2 won the round!")
		finish_round(2)
	elif answer_p1 != -1 and answer_p2 != -1:
		print("Both players lost!")
		finish_round(0)

func finish_round(winner: int) -> void:
	respond_timer.stop()
	if winner == 1:
		score_p1 += 1
	elif winner == 2:
		score_p2 += 1
	
	scoreboard_p1.text = str(score_p1)
	scoreboard_p2.text = str(score_p2)
	
	state = GameState.REVEAL
	#TODO afficher la bonne réponse
	reveal_timer.start()

func _on_respond_timer_timeout() -> void:
	finish_round(0)

func _on_reveal_timer_timeout() -> void:
	start_new_round()
	#TODO end of game if enough points -> emit end_game

func hide_cursor(cursor: NinePatchRect) -> void:
	cursor.hide()
	cursor.reparent(self)

func show_cursor(cursor: NinePatchRect, pos: int) -> void:
	if pos >= n_answer:
		return
	cursor.show()
	cursor.reparent(answerPanels[pos])
	cursor.position = Vector2.ZERO
