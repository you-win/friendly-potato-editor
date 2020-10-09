extends ColorRect

var FriendyPotatoDialogueRunner = preload("res://utils/FriendlyPotatoDialogueRunner.gd")
var DialogueTextLabel = preload("res://entities/DialogueTextLabel.tscn")
var ChoiceContainer = preload("res://entities/ChoiceContainer.tscn")
var ChoiceContainerButton = preload("res://entities/ChoiceContainerButton.tscn")

var dialogue_data: Dictionary

var dialogue

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	# Pass in an empty dictionary for initial_variable_state and functions_to_bind
	# since this is not supported for in-editor tests
	dialogue = FriendyPotatoDialogueRunner.new(dialogue_data, {}, {})
	continue_dialogue()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_choice_selected(button: Button, choice_container: MarginContainer) -> void:
#	dialogue_label_container.remove_child(current_choice_container)
#	current_choice_container.queue_free()
	var index = $MarginContainer.get_node("ChoiceContainer").buttons.find(button)
	
	dialogue.choose_choice(index)
	continue_dialogue()
	
	choice_container.queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func continue_dialogue() -> void:
	var current_text = dialogue.continue_dialogue()
	
	var dialogue_text_label = DialogueTextLabel.instance()
	dialogue_text_label.text = current_text
	
	$MarginContainer/VBoxContainer.add_child(dialogue_text_label)
	
	if not dialogue.should_end:
		var choice_container = ChoiceContainer.instance()
		choice_container.name = "ChoiceContainer"
		if $MarginContainer.get_node_or_null("ChoiceContainer"):
			yield($MarginContainer.get_node("ChoiceContainer"), "tree_exited")
		$MarginContainer.add_child(choice_container)
		for choice in dialogue.current_choices:
			var button = ChoiceContainerButton.instance()
			button.text = choice.choice_name
			button.connect("pressed", self, "_on_choice_selected", [button, choice_container])
			choice_container.get_node("VBoxContainer").add_child(button)
			choice_container.buttons.append(button)
	else:
		queue_free()
