extends Node2D

var value = 0
@onready var valueLabel = $Panel/ValueLabel
@onready var nameLabel = $"Cell Label"

func _ready():
	valueLabel.text = str(value)
	nameLabel.text = "Cell " + self.name.split("l")[2]

func updateValue(val):
	value = val
	valueLabel.text = str(value)
