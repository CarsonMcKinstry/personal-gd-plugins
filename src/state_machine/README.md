# A Node Based State Machine

A node based state machine with context shared between all nodes of the machine.

## Installation

See [the installation guide](https://github.com/CarsonMcKinstry/personal-gd-plugins#installation).

## Usage

A state machine has 3 components:

- The context
- The nodes
- The state machine itself

This is the basic structure in the scene tree:

```bash
RootNode
├── StateContext
└── StateMachine
    ├── StateNodeA
    ├── StateNodeB
    └── StaetNodeC
```

### Nodes

#### StateContext

A context extends the `StateContext` node and
can contain as much or as little data as required by your state nodes. This is generally where you want to define any exports that your state nodes should have access to.

##### Methods

| return | method                  | description                                           |
| ------ | ----------------------- | ----------------------------------------------------- |
| void   | reset() _(virtual-ish)_ | Use this to reset any values in the context as needed |

#### StateNode

A node extends `StateNode` and is where your state logic lives. By default, the process mode is set to disabled and all processing is handled by the parent state machine. Each node has access to the current context, though it will be the base `StateContext`.

Each state node has similar callbacks to a normal `Node`, which are delegated to the current state by the parent state machine:

- `_on_process`
- `_on_physics_process`
- `_on_input`
- `_on_unhandled_input`

Transitioning between states can be done in one of two ways:

- by returning a new state node from one of the virtual processing methods
- by calling `transition_to` with a state node

##### Properties

| name      | type         | description                                                                                                                                                                     |
| --------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| \_context | StateContext | The context that was shared to this node by the state machine. You should wrap this in a getter to ensure it has the correct type. See the [State Nodes](#state-nodes) example. |

##### Signals

| name                 | args      | description                                                                       |
| -------------------- | --------- | --------------------------------------------------------------------------------- |
| transition_requested | StateNode | Emitted up to the state machine to request it begin the transition to a new node. |

##### Methods

| return            | method                           | visibilty | description                                                                                                                                                    |
| ----------------- | -------------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void              | \_enter()                        | virtual   | Called when the state machine transitions to this node.                                                                                                        |
| void              | \_exit()                         | virtual   | Called when the state machine transitions away from this node.                                                                                                 |
| StateNode \| null | \_on_unhandled_input(InputEvent) | virtual   | Proxy for the state machine's `_unhandled_input` callback. Returning a state node will cause the state machine to immediately transition to the returned node. |
| StateNode \| null | \_on_input(InputEvent)           | virtual   | Proxy for the state machine's `_input` callback. Returning a state node will cause the state machine to immediately transition to the returned node.           |
| StateNode \| null | \_on_process(float)              | virtual   | Proxy for the state machine's `_process` callback. Returning a state node will cause the state machine to immediately transition to the returned node.         |
| StateNode \| null | \_on_process_physics(float)      | virtual   | Proxy for the state machine's `_physics_process` callback. Returning a state node will cause the state machine to immediately transition to the returned node. |
| void              | transition_to(StateNode)         | protected |                                                                                                                                                                |

> [!NOTE]
> Remember, StateNodes do not have direct access to their normal callback methods such as `_process` or `_physics_process`. Instead, you hook into them using the `_on_*` virtual methods on the state node.

#### StateMachine

The state machine orchestrates the handling of the child states in the current tree. On ready, the state machine gathers it's child nodes, saves a reference to them in an internal dictionary, and gives them a reference to the context. Finally, it takes the start node that's been set and immediately transitions to it.

#### Exports

| name      | type         | description                                                       |
| --------- | ------------ | ----------------------------------------------------------------- |
| \_context | StateContext | The context node that will be shared among all child state nodes. |
| \_start   | StateNode    | The initial state node for the state machine to use.              |

#### Methods

| return | method                            | visibility | description                                                                                                                                                                             |
| ------ | --------------------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void   | change_state(StateNode)           | public     | Use to change the state machine's current state. Can be called from outside of the state machine's nodes to allow non-state-machine transtitions. **Not recommended**                   |
| void   | chanage_state_by_name(StringName) | public     | Allows the state machine to be updated by just the name of the state node, in the event the calling code does not have access to the state nodes themselves. Again, **not recommended** |

### Example

You are creating a character which plays different animations depending on their state: idle, moving, jumping.

#### Context

Start with a context. We want to give our state nodes access to the character, so we export it

```bash
class_name CharacterContext
extends StateContext

@export var character: Character2D
```

#### State Nodes

Next, we create a base state node to set up some shared functionality

```bash
class_name CharacterStateNode
extends StateNode

var context: CharacterContext:
    get: return _context as CharacterContext
```

Notice we define a new `context` variable. This is to get around gdscripts limitation of not having generics. The base class has a `_context` proprety defined as a `StateContext`. To prevent us from having to cast this every, we can do it once in the base class as a new `context` property.

Next, create our three state nodes.

```bash
class_name IdleState
extends CharacterStateNode

func _enter() -> void:
    context.character.animation_player.play("idle");
```

```bash
class_name RunState
extends CharacterStateNode

func _enter() -> void:
    context.character.animation_player.play("run");
```

```bash
class_name JumpState
extends CharacterStateNode

func _enter() -> void:
    context.character.animation_player.play("jump");
```

On enter, each of our state nodes will reach out to the context, get the character, and play an animation on their animation player.

> [!WARNING]
> I recommend not giving these scripts class names. I've only done so here for convenience. Since class names are global, you can run into naming issues fairly quickly. Besides, for the next part the class name isn't super important.

#### In the scene tree

Back in our scene tree, we can then create the following structure

```bash
CharacterNode2D
├── CharacterContext
└── StateMachine
    ├── IdleState
    ├── RunState
    └── JumpState
```

and set our exports in the inspector.

On the `CharacterContext`, set the `character` export to the root node.

On the `StateMachine`, set the `context` export to the `CharacterContext` node, and the `start` export to the `IdleState` node.

#### Transitioning between states in callbacks

Let's add to our `IdleState` so that we can transition to either our jumping or our running state.

```bash
class_name IdleState
extends CharacterStateNode

@export var jumping_state: CharacterStateNode
@export var running_state: CharacterStateNode

...

func _on_physics_process(_delta: float) -> StateNode:
    if Input.is_action_just_pressed("jump"):
        return jumping_state
    if Input.is_action_just_pressed("move"):
        return running_state

    return null
```

First, we need to export our state nodes so they can be set in the editor. These help us to define which states can transition to which. In the

Then, in `_on_physics_process` we do our normal check for inputs. In this contrived case, jumping causes the `jumping_state` to be returned, moving the `move_state. Otherwise, we return null. **It's important to always return null if you aren't returning as state node.**

Finally, the parent `StateMachine` will pick this up and immediately begin transitioning to the next state, first calling the `_exit` callback of the currently active state.

#### Transitioning between states explicitly

Let's add another state to our tree and call it `AttackState`. This attack state halts the character, performs the attack animation, and then goes back to the `IdleState`. We don't necessarily have a way to handle this directly in one of the callback methods, so we need to use the `transition_to` method on the base `StateNode`.

```bash
class_name AttackState
extends CharacterStateNode

@export idle_state: CharacterStateNode

func _enter() -> void:
    context.character\
        .animation_player\
        .animation_finished\
        .connect(_handle_animation_finished)

    context.character.animation_player.play("attack")

func _exit() -> void:
    context.character\
        .animation_player\
        .animation_finished\
        .disconnect(_handle_animation_finished)


func _handle_animation_finished(_animation_name: string) -> void:
    transition_to(idle_state)
```

In `_enter` we connect to the `animation_finished` signal of the character's animation player, then we immediately tell the player to play the attack animation.

Once the attack animation is finished, we immediately call `transition_to` with the idle state we exported. Again, the state machine will pick up this request and call the `_exit` callback, disconnecting the handle from the `animation_finished` signal.
