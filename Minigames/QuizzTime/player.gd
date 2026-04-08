class_name QuizTimePlayer extends Object

var i : String
var scorebar : TextureProgressBar
var score : int
var cursor : NinePatchRect
var cursor_bp : NinePatchRect
var inputs : Array[String]
var answer : int
var time_score : int

func setup(pi: String, UI: Control, score_max: int):
    i = pi
    scorebar = UI.find_child("ScoreBar" + pi)
    scorebar.max_value = score_max
    score = 0
    cursor = UI.find_child("Cursor9P" + pi)
    cursor_bp = UI.find_child("Cursor9BP")
    inputs = ["Bouton HautGauche P" + pi, "Bouton BasGauche P" + pi, 
        "Bouton HautCentre P" + pi, "Bouton BasCentre P" + pi, 
        "Bouton HautDroite P" + pi, "Bouton BasDroite P" + pi]
    answer = -1
    time_score = 0