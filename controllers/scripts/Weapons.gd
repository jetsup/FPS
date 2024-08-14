extends Node3D

var WEAPON_ANIMATION: AnimationPlayer
var WEAPONS: Array[Node3D]
var SELECTED_WEAPON: Node3D = Node3D.new()
var WEAPON_READY: bool = true
var WEAPON_ANIMATIONS: Array
var MAX_AMMO = {
	"smg": 30,
	"502": 9
}

var FIRING_RATE_PER_MINUTE = {
	"smg": 120.0 / 60.0,
	"502": 130.0 / 60.0
}
var AMMO_COUNT = {
	"smg": 30,
	"502": 9
}
var WEAPON_DAMAGE = {
	"smg": 10,
	"502": 20
}

var ammo_count: int = 0
var weapon_damage: int = 0
var weapon_fire_rate: float = 0.0

var sfx: AudioStreamPlayer3D

var bullet_hole_dark = preload("res://components/bullet_hole_dark.tscn")
#var sfx_configured: bool = false

@onready var sfx_fast_reload: AudioStreamWAV = load("res://assets/sounds/smg reload fast.wav")
@onready var sfx_full_reload: AudioStreamWAV = load("res://assets/sounds/smg reload full.wav")
@onready var sfx_fire: AudioStreamWAV = load("res://assets/sounds/smg fire.wav")
@onready var sfx_empty_fire: AudioStreamWAV = load("res://assets/sounds/smg empty.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	var weapons_count: int = get_child_count()
	for i in range(weapons_count):
		var weapon = get_child(i)
		WEAPONS.append(weapon)
	if len(WEAPONS) > 0:
		change_weapon(1, true)

func _input(event):
	if event.is_action_pressed("reload") and ammo_count == 0 and WEAPON_READY:
		sfx.stream = sfx_full_reload
		WEAPON_ANIMATION.play("reload_full")
		await WEAPON_ANIMATION.animation_finished
		ammo_count = MAX_AMMO.get(SELECTED_WEAPON.name.to_lower())
	elif event.is_action_pressed("reload") and ammo_count > 0 and ammo_count < MAX_AMMO.get(SELECTED_WEAPON.name.to_lower()) and WEAPON_READY:
		sfx.stream = sfx_fast_reload
		WEAPON_ANIMATION.play("reload_fast")
		await WEAPON_ANIMATION.animation_finished
		ammo_count = MAX_AMMO.get(SELECTED_WEAPON.name.to_lower())
	elif event.is_action_pressed("inspect") and Global.player.velocity.length() == 0 and WEAPON_READY and "inspect" in WEAPON_ANIMATIONS:
		WEAPON_ANIMATION.play("inspect")
	elif event.is_action_pressed("holster") and "draw" in WEAPON_ANIMATIONS:
		WEAPON_READY = !WEAPON_READY
		if WEAPON_READY:
			WEAPON_ANIMATION.play("draw")
		else:
			WEAPON_ANIMATION.play("draw", -1, -1.0, true)
	
	if event.is_action_pressed("Weapon Primary"):
		change_weapon(1)
	elif event.is_action_pressed("Weapon Secondary"):
		change_weapon(2)
	elif event.is_action_pressed("Weapon Tertiary"):
		change_weapon(3)
	elif event.is_action_pressed("Weapon Other"):
		change_weapon(4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Global.debug.add_property("Ammo", ammo_count, 2)
	Global.debug.add_property("Weapon", SELECTED_WEAPON.name, 2)
	if Input.is_action_pressed("fire") and not WEAPON_ANIMATION.is_playing() and ammo_count > 0 and WEAPON_READY and "fire" in WEAPON_ANIMATIONS:
		sfx.stream = sfx_fire
		ammo_count -= 1
		WEAPON_ANIMATION.play("fire", -1, weapon_fire_rate)
		# Raycasting
		var camera = Global.player.CAMERA_CONTROLER
		var space_state = camera.get_world_3d().direct_space_state
		var screen_center = get_viewport().size / 2
		var origin = camera.project_ray_origin(screen_center)
		var end = camera.project_ray_normal(screen_center) * 1000
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_bodies = true
		var results = space_state.intersect_ray(query)
		if results:
			print("RayCast:", results)
			draw_bullet(results)
	elif Input.is_action_pressed("fire") and not WEAPON_ANIMATION.is_playing() and ammo_count == 0 and WEAPON_READY and "fire_empty" in WEAPON_ANIMATIONS:
		sfx.stream = sfx_empty_fire
		WEAPON_ANIMATION.play("fire_empty", -1, weapon_fire_rate)

func draw_bullet(results: Dictionary):
	var bullet_mark = bullet_hole_dark.instantiate()
	get_tree().root.add_child(bullet_mark)
	bullet_mark.global_position = results.get("position")
	bullet_mark.look_at(bullet_mark.global_transform.origin + results.get("normal"), Vector3.UP)
	if results.get("normal") != Vector3.UP and results.get("normal") != Vector3.DOWN:
		bullet_mark.rotate_object_local(Vector3(1, 0, 0), 90)
	await get_tree().create_timer(2).timeout
	var fadeout = get_tree().create_tween()
	fadeout.tween_property(bullet_mark, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	bullet_mark.queue_free()

func change_weapon(id: int, init: bool = false):# keyboard press 1,2...
	if id > len(WEAPONS) or SELECTED_WEAPON == WEAPONS[id - 1]:
		return
	
	SELECTED_WEAPON = WEAPONS[id - 1]
	if not init: # we have a weapon already
		WEAPON_ANIMATION.play("draw", -1, -1, true)
		await WEAPON_ANIMATION.animation_finished
		SELECTED_WEAPON.set_visible(false)
	SELECTED_WEAPON.set_visible(true)
	
	sfx_fast_reload = load("res://assets/sounds/" + SELECTED_WEAPON.name.to_lower() + " reload fast.wav")
	sfx_full_reload = load("res://assets/sounds/" + SELECTED_WEAPON.name.to_lower() + " reload full.wav")
	sfx_fire = load("res://assets/sounds/" + SELECTED_WEAPON.name.to_lower() + " fire.wav")
	sfx_empty_fire = load("res://assets/sounds/" + SELECTED_WEAPON.name.to_lower() + " empty.wav")
	
	WEAPON_ANIMATION = SELECTED_WEAPON.get_child(1)
	WEAPON_ANIMATIONS = []
	
	for animation in WEAPON_ANIMATION.get_animation_list():
		WEAPON_ANIMATIONS.append(animation)
	
	sfx = SELECTED_WEAPON.get_child(2)
	
	WEAPON_ANIMATION.play("draw")
	ammo_count = AMMO_COUNT.get(SELECTED_WEAPON.name.to_lower())
	weapon_damage = WEAPON_DAMAGE.get(SELECTED_WEAPON.name.to_lower())
	weapon_fire_rate = FIRING_RATE_PER_MINUTE.get(SELECTED_WEAPON.name.to_lower())
