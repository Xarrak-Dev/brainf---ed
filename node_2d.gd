extends Node2D

@onready var editor = $Editor

var pointer = 0
var cells = {"cell0": 0, "cell1": 0}
var loopStarts = []
var loopEnds = []
var loops = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_process_button_pressed() -> void:
	var unsplit:String = editor.text
	var keywordList:Array = unsplit.split()
	print(keywordList)
	runSimulation(keywordList)

func runSimulation(keywords):
	cells = {"cell0": 0, "cell1": 0}
	pointer = 0
	loopStarts = []
	loopEnds = []
	loops = {}
	var movePointerLeft = func():
		pointer -= 1
	var movePointerRight = func():
		pointer += 1
	var addToCell = func():
		cells["cell" + str(pointer)] += 1
	var unaddToCell = func():
		if cells["cell" + str(pointer)] > 0:
			cells["cell" + str(pointer)] -= 1
	var addLoopStart = func():
		if cells["cell" + str(pointer)] == 0:
			pass
	var addLoopEnd = func():
		if cells["cell" + str(pointer)] != 0:
			pass
	var keyTypes = {"<": movePointerLeft, ">": movePointerRight, "+": addToCell, "-": unaddToCell, "[": addLoopStart, "]": addLoopEnd}
	var instructions = []
	var tempPointer = 0
	var matches = 0
	for key in keywords:
		if keyTypes.has(key):
			tempPointer += 1
			if key == "[":
				loopStarts.append(tempPointer)
				matches += 1
			if key == "]":
				loopEnds.append(tempPointer)
				matches -= 1
			instructions.append(keyTypes[key])
	for key in instructions:
		key.call()
		if pointer > cells.size() - 1:
				pointer = 0
		if pointer < 0:
				pointer = cells.size() - 1
