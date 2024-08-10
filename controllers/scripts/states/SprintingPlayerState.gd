class_name SprintingPlayerState

extends State

@export var ANIMATION: AnimationPlayer
@export var TOP_ANIMATION_SPEED: float = 1.6

func enter() -> void:
	ANIMATION.play("Sprinting", 0.5, 1.0)
	Global.player._speed = Global.player.SPEED_SPRINTING

# Called when the node enters the scene tree for the first time.
func update(delta):
	set_animation_speed(Global.player.velocity.length())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_animation_speed(speed) -> void:
	var alpha = remap(speed, 0.0, Global.player.SPEED_SPRINTING, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)

func _input(event):
	if event.is_action_released("sprint"):
		transition.emit("WalkingPlayerState")
