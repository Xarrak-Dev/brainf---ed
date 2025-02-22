extends Node2D

@onready var level = load("res://level_template.tscn")
@onready var descLabel = $"Puzzle Description"
@onready var dot = $"Completed Dot"
@onready var nextButton = $"Next Page Button"
@onready var prevButton = $"Previous Page Button"
var puzzleNumber = 0
var game = null
var pageNumber = 0
@onready var puzzles = preload("res://basePuzzles.json").data
@onready var puzzle = puzzles[str(puzzleNumber)]

func _ready() -> void:
	createPuzzle()

func createPuzzle():
	if puzzle["description"].size() == 1:
		nextButton.visible = false
		prevButton.visible = false
	updatePage()
	createGame(puzzle["cellNumber"], puzzle["cellSize"], puzzle["allowedFunctions"]["input"], puzzle["allowedFunctions"]["speed"], puzzle["defaultCellSetup"])

func createGame(cellNumber:int = 8, cellSize:int = 8, inputAllowed:bool = true, speedAllowed:bool = true, defaultCells = null):
	game = level.instantiate()
	for child in get_children():
		if child.name == "game":
			child.queue_free()
	game.cellBitSize = cellSize
	game.allowed["input"] = inputAllowed
	game.allowed["speed"] = speedAllowed
	game.name = "game"
	if defaultCells != null:
		game.defaultCells = defaultCells
		game.cells = defaultCells
	else:
		game.fillCells(cellNumber)
	game.simulated.connect(checkGame)
	game.reset.connect(resetGame)
	add_child(game)

func checkGame():
	var solved = false
	if puzzle["solutionType"] == "cell":
		solved = puzzleChecker.checkSolution(puzzle["type"], game.cells, puzzle["solution"])
	if solved:
		dot.modulate = Color(0, 0.69, 0)
		var overlay = load("res://succesfulPuzzle.tscn").instantiate()
		add_child(overlay)
	else:
		dot.modulate = Color(1, 0, 0.067)

func resetGame():
	dot.modulate = Color(1, 1, 1)

func updatePage():
	descLabel.text = puzzle["description"]["page" + str(pageNumber)]

func _on_previous_page_button_pressed() -> void:
	if pageNumber > 0:
		pageNumber -= 1
	else:
		pageNumber = puzzle["description"].size() - 1
	updatePage()


func _on_next_page_button_pressed() -> void:
	if pageNumber < (puzzle["description"].size() - 1):
		pageNumber += 1
	else:
		pageNumber = 0
	updatePage()
