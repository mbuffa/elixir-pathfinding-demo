# PathDemo
This is a live demonstration of the A* pathfinding algorithm implemented in Elixir using LiveView. The algorithm itself is a functional step-by-step version of the famous A* algorithm, which is most commonly used in video games.

Head over to https://path-demo.fly.dev and enjoy!

(It's not supposed to be multiplayer, and it's not instanced, so others might try to move the robot while you do so 😄)

## Context
I hacked together the original version of this demo literally over a weekend, ingesting a lot of content about pathing, and a bit about LiveView, in order to do an internal talk at Pandascore.
I got back to it and refactored the whole thing later to clean it up, so overall, I think this is a great demonstration of some of Elixir capabilities, and how to implement such an algorithm in a functional way, leveraging pattern matching quite extensively.

Please keep in mind that this is, however, not a perfect example of algorithmic efficiency (there's a lot of linear search through lists and it could probably be better), and that there might be mistakes or imprecisions about my implementation.

## Setup
You'll need a working version of Erlang and Elixir.

Then:
```sh
# Install dependencies
mix deps.get
# Start server
mix phx.server
```

You can then navigate to `http://localhost:4000` and start playing!

## How it works
You're welcomed by a tile map, a pair of buttons and a description box.

The demo is split into three phases:
* Waiting for a target: that's where you start. Pick a target to progress,
* Estimating the path: click on the "Find the path" button until you see a trail of foot emojis leading to your destination,
* Walking the path: click on the "Walk the path" button until you reach your destination.

Others have described the algorithm extensively, and will do it better than me. But basically, the idea of the algorithm is to expand around in every directions, calculating both the cost to enter the node (usually named `G cost`) and the distance from this node to the destination (usually named H cost`), resulting in the `F cost` of a node. On each step, we just have to pick the most interesting one (which can lead to some weird behavior when computing in non-obvious scenarios). Once we reached our destination, we can just compute a final path by going backwards and applying the same cost principle, resulting in a "smooth" final path.