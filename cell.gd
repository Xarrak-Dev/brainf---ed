extends Node2D

var value = 0
@onready var valueLabel = $Panel/ValueLabel

func _ready():
	valueLabel.text = str(value)

func updateValue(val):
	value = val
	valueLabel.text = str(value)
