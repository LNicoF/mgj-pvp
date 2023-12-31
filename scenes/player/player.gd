extends KinematicBody2D

onready var _ui := $UI
onready var _animation_player := $AnimationpELUCAr
onready var _chainsaw := $Skeleton2D/RotorMoto
onready var _blood := $Skeleton2D/RotorMoto/Hand2/ParticlesBlood
onready var _chainsawArea := $Skeleton2D/RotorMoto/Hand2/Area2D
onready var _sprite := $Skeleton2D
onready var _attackTimer := $AttackTimer

var velocity := Vector2()
var isAttacking := false

export( int ) var max_health := 100
export( int ) var speed := 250
export( int ) var damage := 10

onready var health := max_health

func _ready():
	_sprite.scale.x *= -1
	_ui.setHealth( health )
	$AnimationBlink.play( "Talk" )
	$Blabla.play()

func _input( event: InputEvent ):
	if event is InputEventMouseButton :
		if event.pressed and event.button_index == BUTTON_RIGHT :
			print( 'hit' )
			hit( 10, position )

func _physics_process(delta):
	velocity = _move()
	velocity = move_and_slide( velocity )
	_attack()
	_animate()

func _attack():
	isAttacking = Input.is_action_pressed( "attack" )
	_animate()
	_blood.emitting = isAttacking and not _chainsawArea.get_overlapping_bodies().empty()
	if isAttacking :
		_aim()
		if _attackTimer.is_stopped() :
			_attackTimer.start()
			_on_AttackTimer_timeout()
	else :
		_attackTimer.stop()
		
func _aim() :
	var distance = _chainsaw.position - get_local_mouse_position()
	if sign( distance.x ) != sign( _sprite.scale.x ) and distance.x != 0 :
		_sprite.scale.x *= -1
	_chainsaw.look_at( get_global_mouse_position() )
	_chainsaw.rotation_degrees += 121


func _move() -> Vector2 :
	var goRight := Input.is_action_pressed( "move_right" )
	var goLeft  := Input.is_action_pressed( "move_left" )
	var goUp 	:= Input.is_action_pressed( "move_up" )
	var goDown 	:= Input.is_action_pressed( "move_down" )

	var xDir := int( goRight ) - int( goLeft )
	var yDir := int( goDown )  - int( goUp )
	var res = Vector2( xDir, yDir ).normalized() * speed

	if xDir == _sprite.scale.x and xDir != 0 :
		_sprite.scale.x *= -1

	return Isometric.calcVec( res )

func _animate() :
	if isAttacking :
		_animation_player.attack()
	elif velocity == Vector2() :
		_animation_player.stopMoving()
	else :
		_animation_player.startMoving()

func hit( rDamage: int, _rPosition: Vector2 ) -> void :
	_setHealth( health - rDamage )

func _setHealth( newHealth: int ) -> void :
	if newHealth <= 0 :
		kill() ; return
	health = newHealth
	_ui.setHealth( health )

func kill() -> void :
	get_tree().change_scene( "res://scenes/GameOver.tscn")

func _on_AttackTimer_timeout():
	print( 'attacking' )
	if not isAttacking :
		return
	for body in _chainsawArea.get_overlapping_bodies() :
		if 'enemy' in body.filename and not body.isAlly :
			body.hit( damage, position )

func _on_Inffluence_body_entered(body:Node):
	print( 'enter' )
	if 'enemy' in body.filename :
		body.startInffluencing()

func _on_Inffluence_body_exited(body:Node):
	print( 'exit' )
	if 'enemy' in body.filename :
		body.stopInffluencing()
