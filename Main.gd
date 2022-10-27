extends Spatial

var ray_origin = Vector3()
var ray_target = Vector3()

onready var player = $Player
onready var hand = $Player/Body/Hand

func _physics_process(delta):
	if is_instance_valid(player):
		var mouse_position = get_viewport().get_mouse_position()
		
		ray_origin = $Camera.project_ray_origin(mouse_position)
		ray_target = ray_origin + $Camera.project_ray_normal(mouse_position) * 1000 #We use 1000 to create a long ray because camera is really away
		
		var space_state = get_world().direct_space_state #Allows to get info about world
		var intersection = space_state.intersect_ray(ray_origin, ray_target, [], 8)
		
		if not intersection.empty():
			var pos = intersection.position
			var look_at_me = Vector3(pos.x, player.translation.y, pos.z)
			player.look_at(look_at_me, Vector3.UP)
			var distance_to_pointer = hand.global_transform.origin - look_at_me
			if distance_to_pointer.length() > 3:
				hand.look_at(look_at_me, Vector3.UP)
