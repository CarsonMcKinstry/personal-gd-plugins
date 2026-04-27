# ThreeWayAnimatedSprite2D

A very specific kind of animated sprite used with a very specific sprite structure. Specifically, it is the structure of the sprites created by Otterisk in their [Hana Caraka Base Character](https://otterisk.itch.io/hana-caraka-base-character) sprite. The sprites are not provided here for licensing reasons. Go give them a shout and grab their free sample if you'd like to give this a try.

## Installation

See [the installation guide](https://github.com/CarsonMcKinstry/personal-gd-plugins#installation).

## Usage

### Format

This expects your `AnimatedSprite2D` sprite frames to be in a very very specific format.

Each sprite is split into multiple different files. For example

- idle.png
- jump.png
- run.png
- walk.png

Each file contains three rows:

1. side
2. down
3. up

So in the sprite frames, these should be created as

- idle_side
- idle_down
- idle_up
- jump_side
- jump_down
- jump_up

and so on. Don't worry though, if an animation doesn't exist with an override, it won't crash the `AnimatedSprite2D`

### Overriding Animations

In the inspector for this node, you will have access to an exported resource called `SpriteTextureOverrides`. Here, you will define an object, `overrides`, which are a map of animation names to `Texture2D`s.

> [!NOTE]
> The reason this is a resource, is so that it is easy to hotswap them later on if you feel so inclined.

At runtime, so long as the animation names exist in your base sprite frames and the `Texture2D` is of the same size and layout as the files above, this will swap out the texture for the `AnimatedSprite2D` for the overrides.
