extends Node3D

@export var WEAPON_ANIMATION: AnimationPlayer
@export var ammo_count: int = 2
@export var MAX_AMMO: int = 5
@export var FIRING_RATE_PER_MINUTE: float = 120/60
@export var WEAPON_READY: bool = true

@onready var shot_audio_changed = ammo_count == 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("SMG Loaded")

func _input(event):
	if event.is_action_pressed("reload") and ammo_count == 0 and WEAPON_READY:
		WEAPON_ANIMATION.play("reload_full")
		ammo_count = MAX_AMMO
	elif event.is_action_pressed("reload") and ammo_count > 0 and ammo_count < MAX_AMMO and WEAPON_READY:
		WEAPON_ANIMATION.play("reload_fast")
		ammo_count = MAX_AMMO
	elif event.is_action_pressed("inspect") and Global.player.velocity.length() == 0 and WEAPON_READY:
		WEAPON_ANIMATION.play("inspect")
	elif event.is_action_pressed("holster"):
		WEAPON_READY = !WEAPON_READY
		print("Weapon Ready:", WEAPON_READY)
		if WEAPON_READY:
			WEAPON_ANIMATION.play("draw")
		else:
			WEAPON_ANIMATION.play("draw", -1, -1.0, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Global.debug.add_property("Ammo", ammo_count, 1)
	if Input.is_action_pressed("fire") and not WEAPON_ANIMATION.is_playing() and ammo_count > 0 and WEAPON_READY:
		ammo_count -= 1
		WEAPON_ANIMATION.play("fire", -1, FIRING_RATE_PER_MINUTE)
	elif Input.is_action_pressed("fire") and not WEAPON_ANIMATION.is_playing() and ammo_count == 0 and WEAPON_READY:
		WEAPON_ANIMATION.play("fire_empty", -1, FIRING_RATE_PER_MINUTE)
