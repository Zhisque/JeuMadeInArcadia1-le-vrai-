extends CharacterBody2D

var direction: Vector2
const speed := 50
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("Joystick Haut P1"):
		direction = Vector2.UP
	if Input.is_action_pressed("Joystick Gauche P1"):
		direction = Vector2.LEFT
	if Input.is_action_pressed("Joystick Bas P1"):
		direction = Vector2.DOWN
	if Input.is_action_pressed("Joystick Droite P1"):
		direction = Vector2.RIGHT
		
	position = direction * speed
	move_and_slide()
