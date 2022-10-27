extends Spatial

export var speed = 70
export var damage = 1

const KILL_TIME = 2 #Desaparecen en 2 segundos
var timer = 0

func _physics_process(delta): #Usamos physics para evitar distintas velocidades por lag
	var forward_direction = global_transform.basis.z.normalized() #Bullet direction
	global_translate(forward_direction * speed * delta)
	
	timer += delta #Suma tiempo aun dependiendo del lag
	if timer >= KILL_TIME:
		queue_free()

func _on_Area_body_entered(body: Node):
	queue_free()
	
	if body.has_node("Stats"):
		var stats_node = body.find_node("Stats") as Stats
		stats_node.take_hit(damage)
