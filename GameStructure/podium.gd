extends Node2D

@onready var GameManager = get_parent()
var message = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not message:
		print("C'est fini !")
		message = true

func _on_timer_timeout() -> void:
	GameManager.next(true)
