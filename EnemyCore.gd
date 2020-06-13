extends KinematicBody2D

var BLOOD_PARTICLES = preload("res://BloodParticles.tscn")

export(int) var ACCELERATION = 500
export(int) var MAX_SPEED = 85
export(int) var FRICTION = 100
export(int) var health = 3
export(int) var knockback = 2
export(int) var screen_shake_intensity = 60
export(int) var score_value = 10


var velocity = Vector2()

var stun = false

onready var sprite = $Sprite
onready var current_color = sprite.modulate

func _process(_delta: float) -> void:
	if health <= 0:
		Global.play_sound("res://enemy-death.wav")
		if Global.camera:
			Global.camera.screen_shake(screen_shake_intensity, 0.2)

		Global.score += score_value
		if Global.node_creation_parent != null:
			var blood_particles = Global.instance_node(BLOOD_PARTICLES, global_position, Global.node_creation_parent)
			blood_particles.rotation = velocity.angle()
			blood_particles.modulate = Color.from_hsv(current_color.h, current_color.s, current_color.v * 0.65)
		queue_free()

func basic_movement_towards_player(delta: float) -> void:
	if Global.player != null and stun == false:
		velocity = velocity.move_toward(global_position.direction_to(Global.player.global_position) * MAX_SPEED, ACCELERATION * delta)
		velocity = move_and_slide(velocity)
	elif stun:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity = move_and_slide(velocity)


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_damager") and stun == false:
		Global.instance_node(area.HIT_EFFECT_SCENE, area.global_position, Global.node_creation_parent)
		Global.play_sound("res://enemy-hurt.wav")
		Global.camera.screen_shake(10, 0.02)
		sprite.modulate = Color.white
		stun = true
		velocity = (-velocity / 2) * knockback
		health -= area.damage
		$StunTimer.start()
		area.queue_free()


func _on_StunTimer_timeout() -> void:
	modulate = Color(current_color)
	stun = false
