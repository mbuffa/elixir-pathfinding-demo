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

  def tile_at(tiles, position) do
    tiles
    |> List.flatten()
    |> Enum.find(fn tile -> tile.position == position end)
  end

  def neighbors_of(tiles, position) do
    tiles
    |> List.flatten()
    |> Enum.filter(fn tile ->
      [x, y] = position
      [tx, ty] = tile.position

      diffx = abs(x - tx)
      diffy = abs(y - ty)

      (diffx == 1 && diffy == 1) or (diffx == 1 && diffy == 0) or (diffy == 1 && diffx == 0)
    end)
  end

  def is_neighbor?(node_position, target_position) do
    distance = manhattan_distance(node_position, target_position)
    distance == 1 or distance == 2
  end
end
