extends KinematicBody

class_name Enemy

onready var nav = $"../Navigation" as Navigation
onready var player = $"../Player" as KinematicBody
onready var attack_timer = $AttackTimer

var default_material = load("res://Enemy/EnemyDefaultMaterial.tres")
var attack_material = load("res://Enemy/EnemyAttackMaterial.tres")
var resting_material = load("res://Enemy/EnemyRestingMaterial.tres")

var path = []
var current_node = 0
var speed = 2
var attack_speed_multiplier = 5
var attack_target: Vector3
var return_target: Vector3

enum state{ #Enemies posibilities
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING
}
var current_state = state.SEEKING

func _ready():
	$MeshInstance.set_surface_material(0, default_material)

func _physics_process(delta):
	if is_instance_valid(player):
		match current_state: #Comprobar estado
			state.SEEKING:
				if current_node < path.size(): #Enemy Movement
					var seeking_vector: Vector3 = path[current_node] - global_transform.origin
					move_and_slide(seeking_vector.normalized() * speed)
					seeking_vector = path[current_node] - global_transform.origin
					if seeking_vector.length() < 1:
						current_node += 1
					if $AttackRadius.overlaps_body(player): #Check if we are close to the player, to attack or not
						init_attack()
			state.ATTACKING:
				move_and_attack()
			state.RETURNING:
				move_and_attack()
			state.RESTING:
				pass
	#			print("RESTING")

func move_and_attack():
	var attack_vector: Vector3 = attack_target - global_transform.origin #Dirección y distancia
	var direction: Vector3 = attack_vector.normalized() #La direccion en la que esta el player
	var distance = attack_vector.length() #Lo lejos que esta el player
	
	move_and_slide(direction * speed * attack_speed_multiplier)
	
	if distance < 1:
		match current_state:
			state.ATTACKING:
				#Do damage to player
				var player_stats: Stats = player.get_node("Stats")
				player_stats.take_hit(1)
				print("I hit you: ", player_stats.current_HP, "/", player_stats.max_HP)
				current_state = state.RETURNING
				attack_target = return_target
			state.RETURNING:
				current_state = state.RESTING
				$MeshInstance.set_surface_material(0, resting_material)
				collide_with_other_enemies(true)
				move_and_slide(Vector3.ZERO)
				attack_timer.start()

func collide_with_other_enemies(should_we_collide): #Para que no choque con otros enemigos al atacar
	set_collision_mask_bit(2, should_we_collide)
	set_collision_layer_bit(2, should_we_collide)

func update_path(target_position):
	path = nav.get_simple_path(global_transform.origin, target_position)

func _on_Stats_you_died_signal():
	queue_free()

func init_attack():
	attack_target = player.global_transform.origin #Atacaran la posicion en la que estaba el player al detectarlo
	return_target = global_transform.origin
	current_state = state.ATTACKING
	$MeshInstance.set_surface_material(0, attack_material)
	collide_with_other_enemies(false)

func _on_PathUpdateTimer_timeout():
	if is_instance_valid(player):
		update_path(player.global_transform.origin)
		current_node = 0

func _on_AttackTimer_timeout():
	current_state = state.SEEKING
	$MeshInstance.set_surface_material(0, default_material)
