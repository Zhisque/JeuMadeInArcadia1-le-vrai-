extends GameUtilities

func _ready() -> void:
	# Appelle la fonciton _ready() de GameUtilities, cette ligne est tres importante
	super()

func _process(delta: float) -> void:
	# Appelle la fonction _process(delta) de GameUtilities, cette ligne est très importante
	super(delta)
	
	if game_started:
		# Votre boucle de jeu
		# Mettez votre logique de jeu ici !
		
		# Votre condition de victoire
		if Input.is_action_just_pressed("Bouton HautGauche P1"):
			# Emmettre end_game signalera la fin de votre jeu
			# L'argument est true si le joueur1 as gagné, et false si le joueur2 as gagné.
			end_game_early.emit()

# Cette fonction sera appelée à la fin d'une partie pour déterminer qui sera le gagnant
# retourne True si joueur1 as gagné, et retourne False si joueur2 as gagné
func get_winner() -> bool:
	return true
