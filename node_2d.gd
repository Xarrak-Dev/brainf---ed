extends Node2D

@onready var editor = $Editor
@onready var cellsNode = $Cells

var pointer = 0
var instPointer = 0
var cells = {"cell0": 0, "cell1": 0, "cell2": 0, "cell3": 0, "cell4": 0, "cell5": 0, "cell6": 0, "cell7": 0}
var loopStarts = []
var loopEnds = []
var loops = {}
var cell = preload("res://cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateCells(cells)


func _on_process_button_pressed() -> void:
	var unsplit:String = editor.text
	var keywordList:Array = unsplit.split()
	runSimulation(keywordList)

func runSimulation(keywords):
	cells = {"cell0": 0, "cell1": 0, "cell2": 0, "cell3": 0, "cell4": 0, "cell5": 0, "cell6": 0, "cell7": 0}
	pointer = 0
	loopStarts = []
	loopEnds = []
	loops = {}
	instPointer = -1
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
		print(cells["cell" + str(pointer)] == 0)
		if (cells["cell" + str(pointer)] == 0):
			print("Hello")
			print(loops[instPointer])
			instPointer = loops[instPointer]
	var addLoopEnd = func():
		print(cells["cell" + str(pointer)] != 0)
		if (cells["cell" + str(pointer)] != 0):
			print("Hello")
			print(loops.find_key(instPointer))
			instPointer = loops.find_key(instPointer)
	var keyTypes = {"<": movePointerLeft, ">": movePointerRight, "+": addToCell, "-": unaddToCell, "[": addLoopStart, "]": addLoopEnd}
	var instructions = []
	var tempPointer = 0
	var matches = 0
	for key in keywords:
		if keyTypes.has(key):
			if key == "[":
				loopStarts.append(tempPointer)
			if key == "]":
				loops[loopStarts.pop_back()] = tempPointer
			instructions.append(keyTypes[key])
			tempPointer += 1
	while instPointer <= (instructions.size() - 2):
		instPointer += 1
		instructions[instPointer].call()
		if pointer > cells.size() - 1:
			pointer = 0
		if pointer < 0:
			pointer = cells.size() - 1
		print(pointer, instPointer, cells, loops)
	for celll in cellsNode.get_children():
		celll.updateValue(cells[celll.name])

func generateCells(cellDict:Dictionary):
	var lastCellPos = Vector2(600, 600)
	print("function called")
	var i = 0
	for celll in cellDict.keys():
		var newCell = cell.instantiate()
		newCell.value = cellDict[celll]
		newCell.position = lastCellPos
		lastCellPos.x += 50
		newCell.name = "cell" + str(i)
		cellsNode.add_child(newCell)
		i += 1

func _on_exit_button_pressed() -> void:
	get_tree().quit()
