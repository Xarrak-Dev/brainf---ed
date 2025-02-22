extends Node2D

#elements, these are used when they need to be updated, read from or have the visibility changed
@onready var editor = $Editor
@onready var cellsNode = $Cells
@onready var outputLabel = $outputLabel
@onready var input = $Input
@onready var pointerLabel = $Pointer
@onready var speedSlider = $HSlider
@onready var processButton = $ProcessButton

@onready var centerOfScreenX = (get_viewport().size.x / self.scale.x) / 2
@onready var viewportSizeY = get_viewport().size.y / self.scale.x

signal simulated
signal reset

#customization settings for creating puzzles
var allowed = {"input":true, "speed": true}
var defaultCells = null
var cellBitSize:int = 8

#these are all of the global variables needed for the various functions
var pointer = 0
var instPointer = 0
var inputPointer = 0
var cells = {}
var loopStarts = []
var loopEnds = []
var loops = {}
var cell = preload("res://cell.tscn")
var inputs = []
var customSpeed = false
var speed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateCells(cells)
	if !allowed["input"]:
		outputLabel.visible = false
		input.visible = false
	if !allowed["speed"]:
		speedSlider.visible = false
	getPositionGood(editor, 10)
	getPositionGood(processButton, 1.75)
	getPositionGood(speedSlider, 15)
	getPositionGood(input, 1.5)
	getPositionGood(outputLabel, 1.15)

func getPositionGood(element, sizeY):
	element.position = Vector2(centerOfScreenX - (element.size.x / 2), viewportSizeY / sizeY)

func _on_process_button_pressed() -> void:
	if processButton.text != "Reset":
		var unsplit:String = editor.text
		var keywordList:Array = unsplit.split()
		runSimulation(keywordList)
		processButton.text = "Reset"
	else:
		if defaultCells != null:
			cells = defaultCells.duplicate(true)
		else:
			var i = 0
			for key in cells:
				cells[key] = 0
				var selectedCell = cellsNode.get_child(i)
				selectedCell.updateValue(cells["cell" + str(i)])
				i += 1
		var i = 0
		for child in cellsNode.get_children():
			child.updateValue(cells["cell" + str(i)])
			i += 1
		reset.emit()
		processButton.text = "Process"
		pointerLabel.position = Vector2(-100, -100)

func fillCells(amount):
	for i in amount:
		cells["cell" + str(i)] = 0

func runSimulation(keywords):
	if defaultCells != null:
		cells = defaultCells.duplicate(true)
	else:
		var i = 0
		for key in cells:
			cells[key] = 0
			var selectedCell = cellsNode.get_child(i)
			selectedCell.updateValue(cells["cell" + str(i)])
			i += 1
	pointer = 0
	loopStarts = []
	loopEnds = []
	loops = {}
	instPointer = -1
	inputPointer = 0
	outputLabel.text = ""
	inputs = input.text.split()
	var movePointerLeft = func():
		pointer -= 1
	var movePointerRight = func():
		pointer += 1
	var addToCell = func():
		if cells["cell" + str(pointer)] > (2 ** cellBitSize) - 2:
			cells["cell" + str(pointer)] = 0
		else:
			cells["cell" + str(pointer)] += 1
	var unaddToCell = func():
		if cells["cell" + str(pointer)] > 0:
			cells["cell" + str(pointer)] -= 1
		else:
			cells["cell" + str(pointer)] = (2 ** cellBitSize) - 1
	var addLoopStart = func():
		if (cells["cell" + str(pointer)] == 0):
			instPointer = loops[instPointer]
	var addLoopEnd = func():
		if (cells["cell" + str(pointer)] != 0):
			instPointer = loops.find_key(instPointer)
	var getInput = func():
		if (inputs.size() - 1) < inputPointer:
			cells["cell" + str(pointer)] = 0
		else:
			cells["cell" + str(pointer)] = inputs[inputPointer].unicode_at(0)
			inputPointer += 1
	var appendToOutput = func():
		outputLabel.text = outputLabel.text + char(cells["cell" + str(pointer)])
	var keyTypes = {"<": movePointerLeft, ">": movePointerRight, "+": addToCell, "-": unaddToCell, "[": addLoopStart, "]": addLoopEnd, ".": appendToOutput, ",": getInput}
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
		var selectedCell = cellsNode.get_child(pointer)
		selectedCell.updateValue(cells[selectedCell.name])
		pointerLabel.position = Vector2((selectedCell.position.x - (24 * scale.x)) / scale.x, (selectedCell.position.y - (50 * scale.x)) / scale.x)
		if customSpeed:
			await get_tree().create_timer(speed).timeout
	for celll in cellsNode.get_children():
		celll.updateValue(cells[celll.name])
	simulated.emit()

func generateCells(cellDict:Dictionary):
	var lastCellPos = Vector2((get_viewport().size.x / 2) - ((25 * self.scale.x) * (cellDict.keys().size() - 1)), get_viewport().size.y / 1.2)
	var i = 0
	for celll in cellDict.keys():
		var newCell = cell.instantiate()
		newCell.value = cellDict[celll]
		newCell.position = lastCellPos
		newCell.scale = self.scale
		lastCellPos.x += (50 * self.scale.x)
		newCell.name = "cell" + str(i)
		cellsNode.add_child(newCell)
		i += 1

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _on_h_slider_value_changed(value: float) -> void:
	if value == 0:
		customSpeed = false
	else:
		customSpeed = true
		if value < 0.05:
			speed = 0
		else:
			speed = value
