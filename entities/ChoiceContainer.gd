extends MarginContainer

var ChoiceContainerButton = preload("res://entities/ChoiceContainerButton.tscn")

var buttons: Array = []

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	pass

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func create_choices(choices_array: Array) -> void:
	for choice in choices_array:
		var button = ChoiceContainerButton.instance()
		button.text = choice.text
