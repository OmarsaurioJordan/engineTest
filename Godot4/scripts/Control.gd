extends Node2D

const aumento = 25
const room_width = 2048
const room_height = 1536
enum {tipoTorpe, tipoHumano, tipoMonster, tipoVacio}

var losfps = 0.0 # 3 variables para procesar los fps
var sumfps = 0.0
var totfps = 0.0
var unidades = 0 # conteo de cantidad de unidades
var tipo = tipoTorpe # el objeto de las entidades actuales en uso
var desiredfps = 30 # fps como referencia minima a alcanzar
var resources = [] # nodos pre cargados
# auxiliares para nodos
var miRaiz = null

func _ready():
	randomize()
	get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	resources.append(load("res://scenes/Torpe.tscn"))
	resources.append(load("res://scenes/Humano.tscn"))
	resources.append(load("res://scenes/Monster.tscn"))
	resources.append(load("res://scenes/Vacio.tscn"))
	miRaiz = get_node("Mundo")
	# crear entidades
	unidades = aumento * 4
	for _r in range(aumento * 4):
		Crear()
	Estadisticas()

func Crear():
	var aux = resources[tipo].instantiate()
	miRaiz.add_child(aux)
	if tipo != tipoVacio:
		aux.raiz = miRaiz
	aux.position = Vector2(randf() * room_width, randf() * room_height)

func Eliminar():
	var aux = miRaiz.get_child(0)
	if aux != null:
		miRaiz.remove_child(aux)
		aux.queue_free()

func Estadisticas():
	get_node("Panel/FPS").text = "FPS: " + str(int(losfps))
	get_node("Panel/Units").text = "Units: " + str(unidades)
	#get_node("Panel/Units").text = "Units: " + str(miRaiz.get_child_count())
	get_node("Panel/Ref").text = "Tab:ref(" + str(desiredfps) + ")"

func _process(delta):
	# obtener los fps crudos
	sumfps += Engine.get_frames_per_second()
	totfps += 1.0

func _input(event):
	# comandos
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ESCAPE:
					get_tree().quit()
				KEY_RIGHT:
					var nue
					match tipo:
						tipoTorpe:
							nue = tipoHumano
						tipoHumano:
							nue = tipoMonster
						tipoMonster:
							nue = tipoVacio
						tipoVacio:
							return 0
					var aux
					for u in miRaiz.get_children():
						aux = resources[nue].instantiate()
						miRaiz.add_child(aux)
						if nue != tipoVacio:
							aux.raiz = miRaiz
						aux.position = u.position
						miRaiz.remove_child(u)
						u.queue_free()
					tipo = nue
				KEY_LEFT:
					var nue
					match tipo:
						tipoTorpe:
							return 0
						tipoHumano:
							nue = tipoTorpe
						tipoMonster:
							nue = tipoHumano
						tipoVacio:
							nue = tipoMonster
					var aux
					for u in miRaiz.get_children():
						aux = resources[nue].instantiate()
						miRaiz.add_child(aux)
						if nue != tipoVacio:
							aux.raiz = miRaiz
						aux.position = u.position
						miRaiz.remove_child(u)
						u.queue_free()
					tipo = nue
				KEY_TAB:
					if desiredfps == 30:
						desiredfps = 15
					else:
						desiredfps = 30
					Estadisticas()
				KEY_BACKSPACE:
					for u in miRaiz.get_children():
						miRaiz.remove_child(u)
						u.queue_free()
					unidades = aumento * 4
					for _r in range(aumento * 4):
						Crear()
					Estadisticas()
				KEY_ENTER:
					unidades += aumento * 4
					for _r in range(aumento * 4):
						Crear()
					Estadisticas()

func _on_Reloj_timeout():
	losfps = round(sumfps / totfps)
	sumfps = 0.0
	totfps = 0.0
	if losfps >= desiredfps or Input.is_key_pressed(KEY_SPACE):
		if losfps > 35.0:
			unidades += aumento * 4
			for _r in range(aumento * 4):
				Crear()
		else:
			unidades += aumento
			for _r in range(aumento):
				Crear()
	elif losfps <= desiredfps - 5:
		if losfps < 5:
			unidades -= aumento * 4
			for _r in range(aumento * 4):
				Eliminar()
		else:
			unidades -= aumento
			for _r in range(aumento):
				Eliminar()
		unidades = max(0, unidades)
	Estadisticas()
