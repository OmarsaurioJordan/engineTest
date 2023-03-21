extends Node2D

const periodo = 1.5
const amplitud = 4.0
const vision = 200.0
const velocidad = 50.0
const ojolen = 3.0
const errarmax = 4.0
const errarmin = 2.0
const radio = 24.0
# auxiliares globales
const pi2 = 2.0 * PI
const room_width = 2048
const room_height = 1536

var anima
var reloj
var mover
var direccion
# auxiliares para nodos
var cabeza = null
var ojo = null
var raiz = null

func _ready():
	anima = randf() * pi2
	reloj = randf_range(errarmin, errarmax)
	mover = randf() < 0.5
	direccion = Vector2(1, 0).rotated(randf() * pi2)
	# obtener nodos
	cabeza = get_node("Cabeza")
	ojo = get_node("Cabeza/Ojo")

func _process(delta):
	# animacion
	anima += delta * pi2 * periodo
	if anima >= pi2:
		anima -= pi2
	cabeza.position.y = amplitud * sin(anima)
	
	# observacion
	var blanco = null
	var mindis = vision
	var d
	for u in raiz.get_children():
		d = position.distance_to(u.position)
		if d < mindis:
			if u != self:
				mindis = d
				blanco = u
	if blanco != null:
		ojo.position = position.direction_to(blanco.position) * ojolen
	else:
		ojo.position = Vector2(0, 0)
	
	# errar
	reloj -= delta
	if reloj <= 0.0:
		reloj += randf_range(errarmin, errarmax)
		mover = randf() < 0.5
		direccion = Vector2(1, 0).rotated(randf() * pi2)
	
	# movimiento
	if mover:
		position += direccion * (velocidad * delta)
	
	# colision
	for u in raiz.get_children():
		if position.distance_to(u.position) < radio:
			if u != self:
				var dd = u.position.direction_to(position)
				var vv = velocidad * delta * 0.5
				position += dd * vv
				u.position += dd * -vv
	
	# limites
	var ant = position
	position.x = clamp(position.x, 0, room_width)
	position.y = clamp(position.y, 0, room_height)
	if ant.x != position.x or ant.y != position.y:
		direccion = Vector2(1, 0).rotated(randf() * pi2)
