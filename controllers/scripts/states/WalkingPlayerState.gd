class_name WalkingPlayerState

extends State

@export var ANIMATION: AnimationPlayer
@export var TOP_ANIMATION_SPEED: float = 2.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func enter() -> void:
	ANIMATION.play("Walking", -1, 1)

func update(_delta):
	set_animation_speed(Global.player.velocity.length())
	if Global.player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")

func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, Global.player.SPEED_DEFAULT, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
