extends Node
class_name Stats

export var max_HP = 10 #Asignamos 10 pero se puede cambiar desde el editor de Stats
onready var current_HP = max_HP

signal you_died_signal

func _ready():
	pass 

func take_hit(damage):
	current_HP -= damage
	print("HIT ", current_HP, "/", max_HP)
	if current_HP <= 0:
		die()

func die():
	emit_signal("you_died_signal")
