extends Node

var score: int = 0
var scriptFragShader = ""
#var scriptFragShader: Shader = null

func add_score(value: int):
	score += value
	print("Score:", score)


func update_script(shader):
	scriptFragShader = shader
	print("hooyooo")
	return scriptFragShader
