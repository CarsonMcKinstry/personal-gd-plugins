# Godot Sequencer

An in-code sequencer that acts like an animation player for more than just properties.

This is essentially a super directed state machine, but defined in code instead of nodes. It is good for sequencing a series of events or actions without needing to get into the weeds of a state machine. A big difference beween this and a state machine is that the actions are ephemeral and only live long enough to be used by the sequencer, without being kept around in memory like nodes in a state machine.

## Why not an Animation Player?

While I was building some of my projects (that never saw the light of day 😅), I found that I wanted to script out animations in a way that wasn't 100% tied to a timeline. For example, moving a character across a grid won't take the same amount of time for every single path. Or perhaps I want to script out what happens when a character uses a specific ability, but that ability might take variable amounts of time to finish. The animation player for both scenarios would become unmaintainable very quickly.

## Installation

See [the installation guide](https://github.com/CarsonMcKinstry/personal-gd-plugins#installation).

## Usage

A sequencer has 3 components:

- The context
- The actions
- The sequencer node itself

At it's most basic, it is used like this:

```bash
func _ready() -> void:
  var sequencer = Sequencer.from([
    Run.new(),
    Jump.new(),
    Fall.new()
  ])

  var context = SquencerContext.new()

  add_child(sequencer)

  sequencer.finished.connect(_handle_finished)

  sequencer.execute(context)
```

1. Create a sequencer and give it a list of actions
2. Create the context
3. Add the sequencer as a child of the current node
4. Connected to the `finished` signal
5. Execute the sequencer with the context.

### Nodes and Objects

#### SequencerContext

A context extends the `SequencerContext` object and can contain as much or as little data as required by your actions. This is generally where you want to define any exports that your actions should have access to.

##### Methods

| return | method                  | description                                           |
| ------ | ----------------------- | ----------------------------------------------------- |
| void   | reset() _(virtual-ish)_ | Use this to reset any values in the context as needed |

#### SequencerAction

An action extends `SequencerAction` and is where the logic for the action lives. Each sequencer action has access to the context for the sequencer through the passed in context on the `_execute` callback.

##### Properties

| name      | type             | description                                                                                                                    |
| --------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| \_context | SequencerContext | The context that was shared to this node by the sequencer. You should wrap this in a getter to ensure it has the correct type. |

##### Signals

| name    | args | description                                                                       |
| ------- | ---- | --------------------------------------------------------------------------------- |
| handled |      | Emitted up to the sequencer to say that the execution of this action is finished. |

##### Methods

| return | method                           | visibilty | description                                                                                |
| ------ | -------------------------------- | --------- | ------------------------------------------------------------------------------------------ |
| void   | \_execute(SequencerContext)      | virtual   | Called by the sequencer for each action in the list                                        |
| void   | \_on_canceled()                  | virtual   | Called by the sequencer in the event that the entire sequence is canceled from the outside |
| void   | \_on_unhandled_input(InputEvent) | virtual   | Proxy for the sequencer's `_unhandled_input` callback.                                     |
| void   | \_on_input(InputEvent)           | virtual   | Proxy for the sequencer's `_input` callback.                                               |
| void   | \_on_process(float)              | virtual   | Proxy for the sequencer's `_process` callback.                                             |
| void   | \_on_process_physics(float)      | virtual   | Proxy for the sequencer's `_physics_process` callback.                                     |
| void   | finished                         | protected | Protected method for easily emitting the handled signal                                    |

#### Sequencer

##### Signals

| name           | args            | description                                                                                           |
| -------------- | --------------- | ----------------------------------------------------------------------------------------------------- |
| finished       |                 | Emitted when all actions have been consumed by the sequencer.                                         |
| canceled       |                 | Emitted when the sequencer has been canceled from outside and the current action has been cleaned up. |
| action_handled | SequencerAction | Emitted when a sequence has been processed and handled.                                               |

##### Methods

| return    | method                          | visibilty | description                                                        |
| --------- | ------------------------------- | --------- | ------------------------------------------------------------------ |
| Sequencer | from(Array\[SequencerAction\])  | static    | Creates a new sequencer from the given array of sequencer actions. |
| void      | execute(SequencerContext)       | public    | Executes the current sequence of actions.                          |
| void      | cancel()                        | public    | Cancels and frees the current sequencer.                           |
| void      | prepend_action(SequencerAction) | public    | Add an action to the front of the action queue.                    |
| void      | append_action(SequencerAction)  | public    | Add an action to the end of the action queue.                      |
| void      | \_on_process_physics(float)     | virtual   | Proxy for the sequencer's `_physics_process` callback.             |
| void      | finished                        | protected | Protected method for easily emitting the handled signal            |

### Example
