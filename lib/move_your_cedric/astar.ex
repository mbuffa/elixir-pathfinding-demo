defmodule MoveYourCedric.Astar do
  defmodule Node do
    defstruct [
      position: nil,
      f: nil,
      g: nil,
      h: nil,
      parent: nil
    ]
  end

  @sample_state %{position: [1, 2], status: :estimating, target: [2, 1]}

  @sample_tiles [
    [
      %MoveYourCedric.Models.Tile{position: [0, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [1, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [2, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [3, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [4, 0], type: :wall},
      %MoveYourCedric.Models.Tile{position: [5, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [6, 0], type: :clear},
      %MoveYourCedric.Models.Tile{position: [7, 0], type: :clear}
    ],
    [
      %MoveYourCedric.Models.Tile{position: [0, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [1, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [2, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [3, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [4, 1], type: :wall},
      %MoveYourCedric.Models.Tile{position: [5, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [6, 1], type: :clear},
      %MoveYourCedric.Models.Tile{position: [7, 1], type: :clear}
    ],
    [
      %MoveYourCedric.Models.Tile{position: [0, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [1, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [2, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [3, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [4, 2], type: :wall},
      %MoveYourCedric.Models.Tile{position: [5, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [6, 2], type: :clear},
      %MoveYourCedric.Models.Tile{position: [7, 2], type: :clear}
    ],
    [
      %MoveYourCedric.Models.Tile{position: [0, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [1, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [2, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [3, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [4, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [5, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [6, 3], type: :clear},
      %MoveYourCedric.Models.Tile{position: [7, 3], type: :clear}
    ],
    [
      %MoveYourCedric.Models.Tile{position: [0, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [1, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [2, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [3, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [4, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [5, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [6, 4], type: :clear},
      %MoveYourCedric.Models.Tile{position: [7, 4], type: :clear}
    ]
  ]

  # G
  def cost_to_enter(position, target) do
    [x, y] = position
    [tx, ty] = target

    case abs(x - tx) + abs(y - ty) do
      0 -> 0
      1 -> 10
      2 -> 14
    end
  end

  # H
  def manhattan_distance(position, target) do
    [x, y] = position
    [tx, ty] = target
    abs(x - tx) + abs(y - ty)
  end

  # TODO: Move those to TileMap model.
  def tile_at(position) do
    sample_tiles() |> Enum.find(fn tile -> tile.position == position end)
  end

  def neighbors_of(position, _tiles) do
    sample_tiles() |> Enum.filter(fn tile ->
      [x, y] = position
      [tx, ty] = tile.position

      diffx = abs(x - tx)
      diffy = abs(y - ty)

      (diffx == 1 && diffy == 1) or (diffx == 1 && diffy == 0) or (diffy == 1 && diffx == 0)
    end)
  end

  def sample_state(), do: @sample_state
  def sample_tiles(), do: @sample_tiles |> List.flatten()


  def yolo_closed_list do
    [%MoveYourCedric.Astar.Node{f: 4, g: 0, h: 4, parent: [1, 2], position: [1, 2]}, %MoveYourCedric.Astar.Node{f: 13, g: 10, h: 3, parent: [1, 2], position: [1, 1]}, %MoveYourCedric.Astar.Node{f: 12, g: 10, h: 2, parent: [1, 1], position: [1, 0]}, %MoveYourCedric.Astar.Node{f: 13, g: 10, h: 3, parent: [1, 2], position: [2, 2]}, %MoveYourCedric.Astar.Node{f: 12, g: 10, h: 2, parent: [2, 2], position: [3, 2]}, %MoveYourCedric.Astar.Node{f: 15, g: 14, h: 1, parent: [1, 1], position: [2, 0]}]
  end

  # def yolo do
  #    open_list = [
  #     %MoveYourCedric.Astar.Node{
  #       f: 18,
  #       g: 14,
  #       h: 4,
  #       parent: [1, 2],
  #       position: [0, 1]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 13,
  #       g: 10,
  #       h: 3,
  #       parent: [1, 2],
  #       position: [1, 1]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 16,
  #       g: 14,
  #       h: 2,
  #       parent: [1, 2],
  #       position: [2, 1]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 15,
  #       g: 10,
  #       h: 5,
  #       parent: [1, 2],
  #       position: [0, 2]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 13,
  #       g: 10,
  #       h: 3,
  #       parent: [1, 2],
  #       position: [2, 2]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 20,
  #       g: 14,
  #       h: 6,
  #       parent: [1, 2],
  #       position: [0, 3]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 15,
  #       g: 10,
  #       h: 5,
  #       parent: [1, 2],
  #       position: [1, 3]
  #     },
  #     %MoveYourCedric.Astar.Node{
  #       f: 18,
  #       g: 14,
  #       h: 4,
  #       parent: [1, 2],
  #       position: [2, 3]
  #     }
  #   ]
  # end
end
