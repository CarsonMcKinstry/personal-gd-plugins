class_name Sequencer
extends Node

signal finished;
signal canceled;
signal action_handled(SequencerAction)

var _queue: Array[SequencerAction] = []

var _executing := false
var _advancing := true
var _canceled := false

var _current_action: SequencerAction

var _context: SequencerContext

static func from(actions: Array[SequencerAction]) -> Sequencer:
	
	var sequencer = Sequencer.new()
	
	sequencer._queue = actions
	
	return sequencer

func execute(context: SequencerContext) -> void:
	if _executing:
		push_warning("%s is already executing" % get_script().get_path())
		return
		
	_executing = true
	_context = context
	
	_process_actions()

func cancel() -> void:
	_canceled = true
	
	if _current_action != null:
		_current_action._on_canceled()
		_current_action.handled.disconnect(_process_actions)
	
	canceled.emit()
	queue_free()

func prepend_action(action: SequencerAction) -> void:
	_queue.push_front(action)
	
func append_action(action: SequencerAction) -> void:
	_queue.push_back(action)

func _process_actions() -> void:
	_advancing = true
	if _current_action != null:
		_current_action.handled.disconnect(_process_actions)
		action_handled.emit(_current_action)
		
	if _queue.is_empty():
		finished.emit()
		queue_free()
		return
		
	_current_action = _queue.pop_front()
	_current_action.handled.connect(_process_actions)
	_current_action._execute(_context)
	_advancing = false

func _unhandled_input(event: InputEvent) -> void:
	if _advancing || _canceled || _current_action == null:
		return
	
	_current_action._on_unhandled_input(event)

func _input(event: InputEvent) -> void:
	if _advancing || _canceled || _current_action == null:
		return
	
	_current_action._on_input(event)

func _physics_process(delta: float) -> void:
	if _advancing || _canceled || _current_action == null:
		return
	
	_current_action._on_physics_process(delta)
	
func _process(delta: float) -> void:
	if _advancing || _canceled || _current_action == null:
		return
	
	_current_action._on_process(delta)
	
