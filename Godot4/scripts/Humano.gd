extends Node2D

const velocidad = 50.0
const ojolen = 3.0
const errarmax = 4.0
const errarmin = 2.0
# auxiliares globales
const room_width = 2048
const room_height = 1536
const pi2 = 2.0 * PI

var mover
var direccion
var colision = []
var observado = []
# auxiliares para nodos
var cabeza
var ojo
var reloj
var raiz
var miBase

func _ready():
	mover = randf() < 0.5
	direccion = Vector2(1, 0).rotated(randf() * pi2)
	# obtener nodos
	cabeza = get_node("Cabeza")
	ojo = get_node("Cabeza/Ojo")
	reloj = get_node("Reloj")
	miBase = get_node("Base")
	# iniciar temporizadores
	reloj.start(randf_range(errarmin, errarmax))
	get_node("Inicia").start(randf() * 1.5)

func _process(delta):
	
	# observacion
	var blanco = null
	var mindis = 10000.0
	var d
	for g in observado:
		d = position.distance_to(g.position)
		if d < mindis:
			mindis = d
			blanco = g
	if blanco != null:
		ojo.position = position.direction_to(blanco.position) * ojolen
	else:
		ojo.position = Vector2(0, 0)
	
	# movimiento
	if mover:
		position += direccion * (velocidad * delta)
	
	# colision
	for c in colision:
		var dd = c.position.direction_to(position)
		var vv = velocidad * delta * 0.5
		position += dd * vv
		c.position += dd * -vv
	
	# limites
	if position.x < 0 or position.x > room_width:
		position.x = clamp(position.x, 0, room_width)
		direccion = Vector2(1, 0).rotated(randf() * pi2)
	if position.y < 0 or position.y > room_height:
		position.y = clamp(position.y, 0, room_height)
		direccion = Vector2(1, 0).rotated(randf() * pi2)

# deteccion de colisiones

func _on_Base_area_entered(area):
	if area != miBase:
		colision.append(area.get_parent())

func _on_Base_area_exited(area):
	if area != miBase:
		colision.erase(area.get_parent())

# errar

func _on_Reloj_timeout():
	reloj.start(randf_range(errarmin, errarmax))
	mover = randf() < 0.5
	direccion = Vector2(1, 0).rotated(randf() * pi2)

# observar cercanos

func _on_Observador_area_entered(area):
	if area != miBase:
		observado.append(area.get_parent())

func _on_Observador_area_exited(area):
	if area != miBase:
		observado.erase(area.get_parent())

# para iniciar la animacion en cualquier posicion

func _on_Inicia_timeout():
	get_node("Inicia").queue_free()
	get_node("Anima").play("idle", -1, 3)
