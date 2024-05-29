defmodule PathDemo.Astar do
  require Logger

  defmodule Node do
    defstruct position: nil,
              f: nil,
              g: nil,
              h: nil,
              parent: nil
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
    distance = abs(x - tx) + abs(y - ty)
    distance * 10
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

  # Core algorithm

  # Final handler: We got nothing to do, we got our path.
  def build_path(_tiles, %{path: %{final_path: final_path}} = state)
      when is_nil(final_path) == false do
    Logger.debug("[ASTAR] Nothing to do, final path is already known.")
    state
  end

  # Initial handler: We haven't done anything yet.
  def build_path(_tiles, %{path: nil} = state) do
    Logger.debug("[ASTAR] Adding starting node to the list.")

    distance = manhattan_distance(state.position, state.target)

    path = %{
      open_list: [
        %Node{
          position: state.position,
          f: 0 + distance,
          g: 0,
          h: distance,
          parent: state.position
        }
      ],
      closed_list: [],
      final_path: nil
    }

    %{state | path: path}
  end

  # Second handler: We just got the initial node in our open list.
  def build_path(tiles, %{path: %{open_list: [current], closed_list: closed_list}} = state) do
    path = %{state.path | closed_list: closed_list ++ [current], open_list: []}

    state = %{state | path: path}

    if state.target == current.position do
      Logger.debug("[ASTAR] Reached destination")

      final_path =
        build_final_path(
          closed_list,
          state.position,
          closed_list |> List.last(),
          [current]
        )

      %{state | path: %{state.path | final_path: final_path}}
    else
      state = %{state | path: compute_path(current, tiles, state)}

      Logger.debug("[ASTAR] Added nodes to the open list.")

      state
    end
  end

  # Third handler: we have multiple nodes in our open list.
  def build_path(tiles, %{path: %{open_list: open_list, closed_list: closed_list}} = state) do
    current =
      open_list
      |> Enum.sort_by(fn node -> {node.f, node.h} end, &<=/2)
      |> List.first()

    new_open_list =
      open_list
      |> Enum.reject(fn node -> node.position == current.position end)

    new_closed_list = closed_list ++ [current]

    new_path = %{state.path | open_list: new_open_list, closed_list: new_closed_list}

    state = %{state | path: new_path}

    if state.target == current.position do
      final_path =
        build_final_path(
          closed_list,
          state.position,
          closed_list |> List.last(),
          [current]
        )
        |> Enum.uniq()

      %{state | path: %{state.path | final_path: final_path}}
    else
      state = %{state | path: compute_path(current, tiles, %{state | path: new_path})}

      state
    end
  end

  defp compute_path(
         current,
         tiles,
         %{path: %{closed_list: closed_list, open_list: open_list}} = state
       ) do
    # We filter our neighbors: we don't want obstacles or nodes in closed_list.
    neighbors =
      neighbors_of(tiles, current.position)
      |> Enum.reject(fn neighbor ->
        in_closed_list =
          closed_list
          |> Enum.any?(fn node -> node.position == neighbor.position end)

        neighbor.type != :clear or in_closed_list
      end)

    Logger.debug("[ASTAR] Rejected invalid neighbors")

    # Calculating best F available.
    shortest_path_available =
      neighbors
      |> Enum.map(fn neighbor ->
        cost_to_enter(current.position, neighbor.position) +
          manhattan_distance(neighbor.position, state.target)
      end)

    Logger.debug("[ASTAR] Calculated shortest path available")

    # Calculate nodes to add to our open list.
    to_add =
      Enum.map(neighbors, fn neighbor ->
        neighbor_in_open_list =
          open_list
          |> Enum.any?(fn node -> node.position == neighbor.position end)

        g = cost_to_enter(current.position, neighbor.position)
        h = manhattan_distance(neighbor.position, state.target)
        f = g + h

        if f <= shortest_path_available or not neighbor_in_open_list do
          node = %Node{
            position: neighbor.position,
            f: f,
            g: g,
            h: h,
            parent: current.position
          }

          if not neighbor_in_open_list do
            node
          else
            nil
          end
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    %{state.path | open_list: open_list ++ to_add}
  end

  defp build_final_path(closed_list, origin, current, path)

  defp build_final_path(_closed_list, [ox, oy], %{position: [ox, oy]}, final_path) do
    Logger.debug("[ASTAR] Finished building final path")
    final_path
  end

  defp build_final_path(closed_list, origin, current, path) do
    Logger.debug("[ASTAR] Building final path")

    parent = Enum.find(closed_list, &(&1.position == current.parent))

    build_final_path(closed_list, origin, parent, [parent, current] ++ path)
  end
end
