extends Spatial

export(PackedScene) var Bullet

onready var rof_timer = $Timer
var can_shoot = true

export var muzzle_speed = 30
export var millis_between_shots = 100 #Millisecond between shots

func _ready():
	rof_timer.wait_time = millis_between_shots / 1000.0 #Dividimos porque esto necesita segundos y le pasamos mili

func _process(delta):
	pass
	
func shoot():
	if can_shoot:
		var new_bullet = Bullet.instance()
		new_bullet.global_transform = $Muzzle.global_transform
		new_bullet.speed = muzzle_speed
		var scene_root = get_tree().get_root().get_children()[0] #Get Root Node
		scene_root.add_child(new_bullet)
		can_shoot = false
		rof_timer.start()

func _on_Timer_timeout():
	can_shoot = true
