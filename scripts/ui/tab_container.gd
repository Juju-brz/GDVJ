extends TabContainer

var code_scene = load("res://UI/code_func.tscn")
var noms_fichiers: Array[String] = []

func _ready() -> void:
	noms_fichiers = lister_fichiers("res://shaders/function/")
	
	# Créer un onglet par fichier, une seule fois
	for nom in noms_fichiers:
		var instance = code_scene.instantiate()
		instance.name = nom.get_basename()  # nom d'onglet propre, sans .gd
		add_child(instance)

#func _process(_delta: float) -> void:
	### TEST ##
	#if Input.is_action_just_pressed("test_add_func"):
		#var instance = code_scene.instantiate()
		#add_child(instance)

func lister_fichiers(path: String) -> Array[String]:
	var array: Array[String] = []
	var dir := DirAccess.open(path)
	
	if dir == null:
		push_warning("Dossier introuvable : " + path)
		return array
	
	dir.list_dir_begin()
	var nom := dir.get_next()
	while nom != "":
		# ignorer les fichiers cachés et .import
		if not dir.current_is_dir() and nom.ends_with(".juju"):
			array.append(nom)
		nom = dir.get_next()
	dir.list_dir_end()
	
	return array

func read_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		pass
	var contain := file.get_as_text()
	file.close()
	return contain
