class_name StateMachine
extends Node

@export var _context: StateContext
@export var _start: StateNode

var _nodes: Dictionary[StringName, StateNode] = {}

var _current: StateNode = null

func _ready() -> void:

	if _context == null:
		push_error("StateContext is not set")
		return
		
	if _start == null:
		push_error("Starting stat is not set")
		return
	
	for child in get_children():
		if child is StateNode:		
			_nodes.set(child.name, child)
			child._initialize(_context)
			
	change_state(_start)
	

func change_state_by_name(state_name: StringName) -> void:
	var node: StateNode = _nodes.get(state_name)
	
	if node == null:
		push_error("State with name %s did not exist when trying to change state by name" % state_name)
		return
	
	change_state(node)

func change_state(next_state: StateNode) -> void:
	if !_nodes.has(next_state.name):
		push_error("State with name %s does not exist" % next_state.name)
		return
		
	if _current != null:
		_current._exit()
		_current.transition_requested.disconnect(_handle_state_transition_request)
		
	_current = next_state
	_current._enter()
	_current.transition_requested.connect(_handle_state_transition_request)
	

func _handle_state_transition_request(next_state: StateNode) -> void:
	change_state(next_state)

func _input(event: InputEvent) -> void:
	if _current == null:
		return
		
	_process_next_state(_current._on_input(event))

func _unhandled_input(event: InputEvent) -> void:
	if _current == null:
		return
	
	_process_next_state(_current._on_unhandled_input(event))
		
func _physics_process(delta: float) -> void:
	if _current == null:
		return
		
	_process_next_state(_current._on_process_physics(delta))
		
func _process(delta: float) -> void:
	if _current == null:
		return
		
	_process_next_state(_current._on_process(delta))
		
func _process_next_state(next_state: StateNode) -> void:
	if next_state == null:
		return
		
	change_state(next_state)
