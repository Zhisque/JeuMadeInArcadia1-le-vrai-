extends Node

# LISTE DES MINIJEUX DU JEU
var minijeux = [] # TODO faire un truc pour selectionner les minijeux disponnibles !!!
var mj_disponibles
var dir = DirAccess.open("res://Minigames")

# ETAT DE LA PARTIE
var etat = ""
var p1_victory = 0
var p2_victory = 0
var nb_manche = 9
var jeu_decisif = 5

func _init() -> void:
	var folders = dir.get_directories()
	
	for folder in folders:
		dir = DirAccess.open("res://Minigames/" + folder)
		var files = dir.get_files()
		if Array(files) != []:
			var scene = ""
			var preview_image = ""
			#RECHERCHE DU JEU ET DE L'IMAGE
			for file in dir.get_files():
				if ".tscn" in file:
					scene = file
				if (".jpg" in file and not ".jpg." in file) or (".png" in file and not ".png." in file):
					preview_image = file
			#VERFICATION DES ELEMENTS DEMANDES
			if scene != "" and preview_image != "":
				minijeux.append([scene,load("res://Minigames/" + folder + "/" + preview_image),folder])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mj_disponibles = minijeux
	
	var scene = load("res://GameStructure/ecran_titre.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	etat = "Menu"
	
func next(conditions,chemin = null) -> void:
	
	if conditions:
		# RETRAIT DE LA SCENE ACTUELLE
		var enfant = get_child(0)
		enfant.queue_free()
		
		if etat == "FinJeu":
			
			# RETOUR AU MENU
			var scene = load("res://GameStructure/ecran_titre.tscn")
			var instance = scene.instantiate()
			add_child(instance)
			
			# CHANGEMENT D'ETAT
			etat = "Menu"
		
		elif etat == "Menu" or etat == "FinManche":
			# RETOUR AU MENU
			var scene = load("res://GameStructure/ecran_de_selection.tscn")
			var instance = scene.instantiate()
			instance.miniature = mj_disponibles
			add_child(instance)
			
			# TODO changer la liste des mj_disponibles
			
			# CHANGEMENT D'ETAT
			etat = "Selection"
			
		elif etat == "Selection":
			# RETOUR AU MENU
			var scene = load(chemin)
			var instance:GameUtilities = scene.instantiate()
			
			# Connexion du signal de fin de partie
			# Donc une fois que la fin de partie sera atteinte, MinigameResults sera appelée.
			instance.end_game.connect(MinigameResults)
			add_child(instance)
			
			# CHANGEMENT D'ETAT
			etat = "Minijeu"
			
		elif etat == "Minijeu" and (p1_victory >= jeu_decisif or p2_victory >= jeu_decisif):
			# RETOUR AU MENU
			var scene = load("res://GameStructure/podium.tscn")
			var instance = scene.instantiate()
			add_child(instance)
			
			# CHANGEMENT D'ETAT
			etat = "FinJeu"
			
		elif etat == "Minijeu" and p1_victory < jeu_decisif and p2_victory < jeu_decisif:
			# RETOUR AU MENU
			var scene = load("res://GameStructure/vainqueur.tscn")
			var instance = scene.instantiate()
			add_child(instance)
			
			# CHANGEMENT D'ETAT
			etat = "FinManche"

# LANCE LE MINIJEU ET LE RETIRE DE LA LISTE DES MINIJEUX DISPONIBLES 
func MinigameSelected(minigame,image,folder) -> void:
	mj_disponibles.erase([minigame,image,folder])
	next(true,"res://Minigames/" + folder + "/" + minigame)

func MinigameResults(result) -> void:
	if result:
		p1_victory += 1
	else:
		p2_victory += 1
	print()
	print("Joueur 1 : ",p1_victory," / Joueur 2 : ",p2_victory)
		
	next(true)
