extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE: 
			idle_state(delta)
		WANDER:
			wander_state(delta)
		CHASE:
			chase_state(delta)
	
	handle_bat_overlap(delta)
	velocity = move_and_slide(velocity)
	
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 125
	hurtbox.create_hit_effect()
	
func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

# States
func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	check_wander_timer()
	
func wander_state(delta):
	seek_player()
	check_wander_timer()
	move_towards(wanderController.target_position, delta)
	check_wander_distance(delta)
	
func chase_state(delta):
	var player = playerDetectionZone.player
	if player != null:
		move_towards(player.global_position, delta)
	else:
		state = IDLE

# Other
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func handle_bat_overlap(delta):
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func pick_ranrom_state_for_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_timer(rand_range(1, 3))

func move_towards(position, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func check_wander_timer():
	if wanderController.get_time_left() == 0:
		pick_ranrom_state_for_wander()
	
func check_wander_distance(delta):
	if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta:
		pick_ranrom_state_for_wander()
	
