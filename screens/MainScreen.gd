extends Control

const VARIABLE_TYPES = {
	"FLOAT": "FLOAT",
	"STRING": "STRING",
	"BOOL": "BOOL"
}

const NODE_SPACING: Vector2 = Vector2(300, 545)
const MAX_SPAWN_ROW_COUNT: int = 9

var DialogueNode: Resource = preload("res://entities/DialogueNode.tscn")
var GlobalVariable: Resource = preload("res://entities/GlobalVariable.tscn")
var DialogueScreen: Resource = preload("res://screens/DialogueScreen.tscn")

var SaveFilePicker: Resource = preload("res://entities/SaveFilePicker.tscn")
var SaveConfirmation: Resource = preload("res://entities/SaveConfirmation.tscn")
var LoadFilePicker: Resource = preload("res://entities/LoadFilePicker.tscn")

var session_saved_project: Dictionary
var session_saved_project_path: String

onready var editor_container: Control = $MarginContainer/HBoxContainer/EditorContainer
onready var editor: GraphEdit = $MarginContainer/HBoxContainer/EditorContainer/GraphEdit

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	# Drag and drop file loading
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	
	# Add node by button
	$MarginContainer/HBoxContainer/ToolBar/AddNodeButton.connect("pressed", self, "_on_add_node_button_pressed")
	
	# Run dialogue in editor
	$MarginContainer/HBoxContainer/ToolBar/RunDialogueButton.connect("pressed", self, "_on_run_dialogue_button_pressed")
	$MarginContainer/HBoxContainer/ToolBar/StopDialogueButton.connect("pressed", self, "_on_stop_dialogue_button_pressed")
	
	# Filesystem
	$MarginContainer/HBoxContainer/ToolBar/SaveButtonContainer/SaveButton.connect("pressed", self, "_on_save_button_pressed")
	if OS.get_name() != "HTML5":
		$MarginContainer/HBoxContainer/ToolBar/SaveButtonContainer/SaveAsButton.connect("pressed", self, "_on_save_as_button_pressed")
	else:
		$MarginContainer/HBoxContainer/ToolBar/SaveButtonContainer/SaveAsButton.queue_free()
	
	if OS.get_name() != "HTML5":
		$MarginContainer/HBoxContainer/ToolBar/LoadButtonContainer/AppendButton.connect("pressed", self, "_on_append_button_pressed")
		$MarginContainer/HBoxContainer/ToolBar/LoadButtonContainer/LoadButton.connect("pressed", self, "_on_load_button_pressed")
	else:
		$MarginContainer/HBoxContainer/ToolBar/LoadButtonContainer/AppendButton.queue_free()
		$MarginContainer/HBoxContainer/ToolBar/LoadButtonContainer/LoadButton.queue_free()
	
	# Global variables
	$MarginContainer/HBoxContainer/ToolBar/AddVariableButton/Button.connect("pressed", self, "_on_add_variable_button_pressed")
	
	# Clear all work
	$MarginContainer/HBoxContainer/ToolBar/ClearButton.connect("pressed", self, "_on_clear_button_pressed")
	
	# Quit
	if OS.get_name() != "HTML5":
		$MarginContainer/HBoxContainer/ToolBar/QuitButton.connect("pressed", self, "_on_quit_button_pressed")
	else:
		$MarginContainer/HBoxContainer/ToolBar/QuitButton.queue_free()

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("control"):
		# Add new node
		if Input.is_action_just_pressed("enter"):
			var dialogue_node_instance: GraphNode = DialogueNode.instance()
			editor.add_child(dialogue_node_instance)
		
		# Zoom editor
		if event.is_action_pressed("zoom_in"):
			editor.zoom += 0.1
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("zoom_out"):
			editor.zoom -= 0.1
			get_tree().set_input_as_handled()
		
		# Save
		if Input.is_action_just_pressed("s"):
			if get_node_or_null("SaveFilePicker"):
				return
			
			if session_saved_project_path:
				_on_save_button_pressed()
			else:
				_on_save_as_button_pressed()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_files_dropped(files: PoolStringArray, screen: int) -> void:
	_load_from_drag_and_drop(files[0])

func _on_add_node_button_pressed() -> void:
	var dialogue_node_instance: GraphNode = DialogueNode.instance()
	editor.add_child(dialogue_node_instance)

func _on_run_dialogue_button_pressed() -> void:
	var dialogue_data = _create_dictionary_from_graphs()
	if dialogue_data["dialogue"].empty():
		return
	if get_node_or_null("MarginContainer/HBoxContainer/EditorContainer/DialogueScreen"):
		return
	
	$MarginContainer/HBoxContainer/ToolBar/StopDialogueButton.visible = true
	editor.pause_mode = Node.PAUSE_MODE_STOP
	
	var dialogue_screen = DialogueScreen.instance()
	dialogue_screen.dialogue_data = dialogue_data
	
	editor_container.add_child(dialogue_screen)
	
	yield(dialogue_screen, "tree_exited")
	
	editor.pause_mode = Node.PAUSE_MODE_INHERIT
	$MarginContainer/HBoxContainer/ToolBar/StopDialogueButton.visible = false

func _on_stop_dialogue_button_pressed() -> void:
	if editor_container.get_node_or_null("DialogueScreen"):
		editor_container.get_node("DialogueScreen").queue_free()
		editor.pause_mode = Node.PAUSE_MODE_INHERIT

func _on_save_button_pressed() -> void:
	var result: Dictionary = _create_dictionary_from_graphs()
	
	if OS.get_name() != "HTML5":
		var save_file: File = File.new()
		save_file.open(session_saved_project_path, File.WRITE)
		
		save_file.store_line(to_json(result))
		save_file.close()
		
		var save_confirmation: AcceptDialog = SaveConfirmation.instance()
		save_confirmation.dialog_text = "File saved at " + session_saved_project_path
		add_child(save_confirmation)
	else:
		var save_file: File = File.new()
		save_file.open("res://" + result["name"] + ".json", File.WRITE)
		
		save_file.store_line(to_json(result))
		save_file.close()
		
		var js_snippet = """
			var dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent('%s');
			var downloadAnchorNode = document.createElement('a');
			downloadAnchorNode.setAttribute('href',     dataStr);
			downloadAnchorNode.setAttribute('download','%s.json');
			document.body.appendChild(downloadAnchorNode); // required for firefox
			downloadAnchorNode.click();
			downloadAnchorNode.remove();
		""" % [to_json(result), result["name"]]
		
		JavaScript.eval(js_snippet)

func _on_save_as_button_pressed() -> void:
	var result: Dictionary = _create_dictionary_from_graphs()
	
	session_saved_project = result
	
	var save_file_picker: FileDialog = SaveFilePicker.instance()
	save_file_picker.save_data = result
	add_child(save_file_picker)

func _on_load_button_pressed() -> void:
	_clear()
	_load_file()

func _on_append_button_pressed() -> void:
	_load_file()

func _on_add_variable_button_pressed() -> void:
	var global_variable_instance: VBoxContainer = GlobalVariable.instance()
	$MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.add_child(global_variable_instance)

func _on_clear_button_pressed() -> void:
	_clear()

# TODO debug only, add a popup dialogue later?
func _on_quit_button_pressed() -> void:
	get_tree().quit()

###############################################################################
# Private functions                                                           #
###############################################################################

func _create_dictionary_from_graphs() -> Dictionary:
	var result: Dictionary = _parse_global_options()
	result["dialogue"] = _parse_dialogue_nodes()
	
	return result

func _parse_global_options() -> Dictionary:
	"""
	Parse global options from the toolbar.
	"""
	print_debug("Parsing global options")

	var result: Dictionary = {}
	
	result["name"] = $MarginContainer/HBoxContainer/ToolBar/TitleContainer/LineEdit.text
	result["initial_dialogue_node"] = $MarginContainer/HBoxContainer/ToolBar/InitialNodeContainer/LineEdit.text
	
	var variables: Dictionary = {}
	for v in $MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.get_children():
		var variable_type: String = v.get_node("Type").get_node("LineEdit").text
		
		variables[v.get_node("Name").get_node("LineEdit").text] = {
			"type": variable_type,
			"value": _convert_variable_to_type(v.get_node("Value").get_node("LineEdit").text, variable_type)
		}
	
	result["variables"] = variables
	
	print_debug("Finished parsing global options")
	
	return result

func _parse_dialogue_nodes() -> Dictionary:
	"""
	Loop through all dialogue nodes and parse all options.
	"""
	print_debug("Parsing dialogue nodes")
	
	var result: Dictionary = {}
	
	for n in editor.get_children():
		if n is GraphNode:
			var dialogue: Dictionary = {}
			dialogue["node_text"] = n.get_node("Text").get_node("TextEdit").text
			dialogue["should_end"] = n.get_node("ShouldEnd").get_node("CheckBox").pressed
			dialogue["choices"] = _parse_choices(n.get_node("Choices").get_children())
			dialogue["on_enter_set_variables"] = _parse_enter_exit_variables(n.get_node("OnEnterSetVariables").get_children())
			dialogue["on_enter_functions"] = _parse_enter_exit_functions(n.get_node("OnEnterFunctions").get_children())
			
			result[n.get_node("Name").get_node("LineEdit").text] = dialogue
	
	print_debug("Finshed parsing dialogue nodes")
	
	return result

func _parse_choices(choices: Array) -> Array:
	"""
	Parse each choice and return an Array of Dictionaries.
	"""
	var result: Array = []
	
	for c in choices:
		var choice: Dictionary = {}
		choice["choice_name"] = c.get_node("Name").get_node("LineEdit").text
		choice["removable"] = c.get_node("Removable").get_node("CheckBox").pressed
		choice["next_node"] = c.get_node("NextNode").get_node("LineEdit").text
		choice["conditional"] = c.get_node("Conditional").get_node("CheckBox").pressed
		choice["conditional_variables"] = _parse_conditional_variables(c.get_node("ConditionalVariables").get_children())
		choice["on_exit_set_variables"] = _parse_enter_exit_variables(c.get_node("OnExitSetVariables").get_children())
		choice["on_exit_functions"] = _parse_enter_exit_functions(c.get_node("OnExitFunctions").get_children())
		
		result.append(choice)
	
	return result

func _parse_conditional_variables(conditional_variables: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for c in conditional_variables:
		var conditional: Dictionary = {}
		var conditional_name: String = c.get_node("Name").get_node("LineEdit").text
		conditional["operator"] = c.get_node("Operator").get_node("LineEdit").text
		
		for child in $MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.get_children():
			if conditional_name == child.get_node("Name").get_node("LineEdit").text:
				conditional["value"] = _convert_variable_to_type(c.get_node("Value").get_node("LineEdit").text, child.get_node("Type").get_node("LineEdit").text)
			else:
				printerr("Conditional variable not found in Global Variable context")
		
		result[conditional_name] = conditional
	
	return result

func _parse_enter_exit_variables(variables: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for v in variables:
		result[v.get_node("Name").get_node("LineEdit").text] = v.get_node("Value").get_node("LineEdit").text
	
	return result

func _parse_enter_exit_functions(functions: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for f in functions:
		var params: Array = []
		for p in f.get_node("Params").get_children():
			params.append(_convert_variable_to_type(p.get_node("Value").get_node("LineEdit").text, p.get_node("Type").get_node("LineEdit").text))
		
		result[f.get_node("Function").get_node("LineEdit").text] = params
	
	return result

func _load_global_options(options: Dictionary) -> void:
	$MarginContainer/HBoxContainer/ToolBar/TitleContainer/LineEdit.text = options["name"]
	$MarginContainer/HBoxContainer/ToolBar/InitialNodeContainer/LineEdit.text = options["initial_dialogue_node"]
	
	for v_key in options["variables"].keys():
		var global_variable_instance = GlobalVariable.instance()
		global_variable_instance.get_node("Name/LineEdit").text = v_key
		global_variable_instance.get_node("Type/LineEdit").text = options["variables"][v_key]["type"]
		global_variable_instance.get_node("Value/LineEdit").text = options["variables"][v_key]["value"]
		
		$MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.add_child(global_variable_instance)

func _load_dialogue_nodes(node_dictionary: Dictionary) -> void:
	var current_spawn_position: Vector2 = Vector2.ZERO
	var current_row_count: int = 0
	for n_key in node_dictionary.keys():
		var d_instance = DialogueNode.instance()
		d_instance.name = n_key
		d_instance.get_node("Name/LineEdit").text = n_key
		d_instance.get_node("Text/TextEdit").text = node_dictionary[n_key]["node_text"]
		d_instance.get_node("ShouldEnd/CheckBox").pressed = node_dictionary[n_key]["should_end"]
		for c in node_dictionary[n_key]["choices"]:
			d_instance.get_node("Choices").add_child(_create_choice(c))
		for ev_key in node_dictionary[n_key]["on_enter_set_variables"].keys():
			d_instance.get_node("OnEnterSetVariables").add_child(_create_enter_exit_variable(ev_key, node_dictionary[n_key]["on_enter_set_variables"][ev_key]))
		for ef_key in node_dictionary[n_key]["on_enter_functions"].keys():
			d_instance.get_node("OnEnterFunctions").add_child(_create_enter_exit_function(ef_key, node_dictionary[n_key]["on_enter_functions"][ef_key]))
		
		if current_row_count > MAX_SPAWN_ROW_COUNT:
			current_spawn_position.y += NODE_SPACING.y
			current_spawn_position.x = 0
			current_row_count = 0
		
		d_instance.offset = current_spawn_position
		current_spawn_position.x += NODE_SPACING.x
		current_row_count += 1
		
		editor.add_child(d_instance)

func _create_choice(choice_dictionary: Dictionary) -> VBoxContainer:
	var choice_option = load("res://entities/ChoiceOption.tscn").instance()
	choice_option.get_node("Name/LineEdit").text = choice_dictionary["choice_name"]
	choice_option.get_node("Removable/CheckBox").pressed = choice_dictionary["removable"]
	choice_option.get_node("NextNode/LineEdit").text = choice_dictionary["next_node"]
	choice_option.get_node("Conditional/CheckBox").pressed = choice_dictionary["conditional"]
	for cv_key in choice_dictionary["conditional_variables"].keys():
		choice_option.get_node("ConditionalVariables").add_child(_create_conditional_variable(cv_key, choice_dictionary["conditional_variables"][cv_key]))
	for exit_var in choice_dictionary["on_exit_set_variables"].keys():
		choice_option.get_node("OnExitSetVariables").add_child(_create_enter_exit_variable(exit_var, choice_dictionary["on_exit_set_variables"][exit_var]))
	for exit_func in choice_dictionary["on_exit_functions"].keys():
		choice_option.get_node("OnExitFunctions").add_child(_create_enter_exit_function(exit_func, choice_dictionary["on_exit_functions"][exit_func]))
	
	return choice_option

func _create_conditional_variable(var_name: String, variable_dictionary: Dictionary) -> VBoxContainer:
	var conditional_variable = load("res://entities/ConditionalVariable.tscn").instance()
	conditional_variable.get_node("Name/LineEdit").text = var_name
	conditional_variable.get_node("Operator/LineEdit").text = variable_dictionary["operator"]
	conditional_variable.get_node("Value/LineEdit").text = variable_dictionary["value"]
	
	return conditional_variable

func _create_enter_exit_variable(variable_name: String, value) -> VBoxContainer:
	var variable = load("res://entities/SetVariable.tscn").instance()
	variable.get_node("Name/LineEdit").text = variable_name
	variable.get_node("Value/LineEdit").text = str(value)
	
	return variable

func _create_enter_exit_function(function_name: String, params: Array) -> VBoxContainer:
	var function = load("res://entities/Function.tscn").instance()
	function.get_node("Function/LineEdit").text = function_name
	for p in params:
		function.get_node("Params").add_child(_create_function_parameter(p))
	
	return function

func _create_function_parameter(param_value) -> VBoxContainer:
	var function_parameter = load("res://entities/FunctionParameter.tscn").instance()
	function_parameter.get_node("Type/LineEdit").text = _get_type_of_variable(param_value)
	function_parameter.get_node("Value/LineEdit").text = param_value
	
	return function_parameter

func _convert_variable_to_type(value, type: String):
	match type:
		VARIABLE_TYPES.FLOAT:
			return float(value)
		VARIABLE_TYPES.STRING:
			return str(value)
		VARIABLE_TYPES.BOOL:
			return bool(value)

func _get_type_of_variable(value) -> String:
	match typeof(value):
		TYPE_BOOL:
			return VARIABLE_TYPES.BOOL
		TYPE_REAL:
			return VARIABLE_TYPES.FLOAT
		TYPE_STRING:
			return VARIABLE_TYPES.STRING
		_:
			printerr("Unrecognized type for value: " + value)
			return VARIABLE_TYPES.STRING

func _load_file() -> void:
	var load_file_picker: FileDialog = LoadFilePicker.instance()
	add_child(load_file_picker)
	
	yield(load_file_picker,"file_selected")
	
	var save_data: Dictionary = load_file_picker.save_data
	load_file_picker.queue_free()
	
	_load_global_options(save_data)
	_load_dialogue_nodes(save_data["dialogue"])

func _load_from_drag_and_drop(path: String) -> void:
	var save_file: File = File.new()
	save_file.open(path, File.READ)
	
	var save_data = parse_json(save_file.get_line())
	
	save_file.close()
	
	_load_global_options(save_data)
	_load_dialogue_nodes(save_data["dialogue"])

func _clear() -> void:
	if editor_container.get_node_or_null("DialogueScreen"):
		editor_container.get_node("DialogueScreen").queue_free()
		editor.pause_mode = Node.PAUSE_MODE_INHERIT
	else:
		for v_child in $MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.get_children():
			v_child.queue_free()
		for e_child in editor.get_children():
			if e_child is GraphNode:
				e_child.queue_free()
		session_saved_project = {}
		session_saved_project_path = ""
		hide_save_button()

###############################################################################
# Public functions                                                            #
###############################################################################

func show_save_button() -> void:
	$MarginContainer/HBoxContainer/ToolBar/SaveButtonContainer/SaveButton.visible = true

func hide_save_button() -> void:
	$MarginContainer/HBoxContainer/ToolBar/SaveButtonContainer/SaveButton.visible = false
