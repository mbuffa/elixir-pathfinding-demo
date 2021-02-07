defmodule MoveYourCedric.Models.Player do
  use GenServer

  require Logger

  alias MoveYourCedric.Astar

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    state = %{
      position: nil,
      status: :idle,
      target: nil,
      path: nil
    }
    {:ok, state}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:get_position, _from, state) do
    {:reply, state.position, state}
  end

    def handle_call(:get_target, _from, state) do
    {:reply, state.target, state}
  end

  def handle_cast({:set_position, position}, state) do
    Logger.debug("[PLAYER] Setting position to #{ inspect position }")
    {:noreply, %{state | position: position}}
  end

  def handle_cast({:pick_target, position}, state) do
    new_state = pick_target(position, state)
    Logger.debug("[PLAYER] Setting target to #{ inspect new_state.target }")
    {:noreply, new_state}
  end

  # Initial handler: We haven't done anything yet.
  def handle_cast({:update_path, _tiles}, %{path: nil} = state) do
    Logger.debug("[PLAYER] Adding starting node to the list.")

    distance = Astar.manhattan_distance(state.position, state.target)

    path = %{
      open_list: [
        %Astar.Node{
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

    {:noreply, %{state | path: path }}
  end

  # Final handler: We got nothing to do, we got our path.
  def handle_cast({:update_path, _tiles}, %{path: %{final_path: final_path}} = state) when is_nil(final_path) == false do
    Logger.debug("[PLAYER] Nothing to do.")
    {:noreply, state}
  end

  # Second handler: We just got the initial node in our open list.
  def handle_cast({:update_path, tiles},
                  %{path: %{open_list: [current], closed_list: closed_list}} = state) do
    path =
      %{state.path | closed_list: closed_list ++ [current],
                     open_list: []}

    IO.puts("[PLAYER] Path state looks like: #{ inspect path }")

    state = %{ state | path: path }

    if state.target == current.position do
      Logger.debug("[PLAYER] Done.")

      path_with_final =
        %{state.path | final_path: build_final_path(
          closed_list,
          state.position,
          closed_list |> List.last(),
          [])}

      IO.puts "Final path"
      IO.inspect path_with_final.final_path

      {:noreply, %{state | path: path_with_final}}
    else
      state = %{state | path: compute_path(current, tiles, state)}

      Logger.debug("[PLAYER] Added nodes to the open list: #{ inspect state.path.open_list }")

      {:noreply, state}
    end
  end

  def handle_cast({:update_path, tiles},
                  %{path: %{open_list: open_list, closed_list: closed_list}} = state) do
    current =
      open_list
      |> Enum.sort_by(fn node -> {node.f, node.h} end, &<=/2)
      |> List.first

    # IO.puts "Got this current:"
    # IO.inspect current
    # IO.puts "Got this open list:"
    # IO.inspect open_list
    # IO.puts "Got this closed list:"
    # IO.inspect closed_list

    new_open_list =
      open_list
      |> Enum.reject(fn node -> node.position == current.position end)

    new_closed_list = closed_list ++ [current]

    new_path =
      %{state.path | open_list: new_open_list,
                     closed_list: new_closed_list}

    state =
      %{state | path: new_path}

    if state.target == current.position do
      Logger.debug("[PLAYER] Done.")

      path_with_final =
        %{state.path | final_path: build_final_path(
          closed_list,
          state.position,
          closed_list |> List.last(),
          [])}

      IO.puts "Final path"
      IO.inspect path_with_final.final_path

      {:noreply, %{state | path: path_with_final}}
    else
      state = %{state | path: compute_path(current, tiles, %{state | path: new_path})}

      {:noreply, state}
    end
  end

  # Debug fallback
  def handle_cast({:update_path, _tiles}, state) do
    Logger.debug("[PLAYER] Fallback receiving:")
    IO.inspect state.path

    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: nil} = state) do
    Logger.debug("[PLAYER] Aye aye aye, pick a target first.")
    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: nil}} = state) do
    Logger.debug("[PLAYER] Aye aye aye, pick a target first.")
    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: []}} = state) do
    Logger.debug("[PLAYER] Reached destination.")

    new_path =
      %{state.path | final_path: nil}

    state =
      %{state | path: new_path,
                position: state.target,
                status: :idle,
                target: nil}

    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: [head | tail]}} = state) do
    Logger.debug("[PLAYER] Walking the path, received #{inspect head} and #{inspect tail}.")

    new_path =
      %{state.path | final_path: tail}

    state =
      %{state | path: new_path,
                position: head.position,
                status: :moving}

    {:noreply, state}
  end

  def update_path(tiles) do
    GenServer.cast(__MODULE__, {:update_path, tiles})
  end

  def walk_path() do
    GenServer.cast(__MODULE__, :walk_path)
  end

  def get_status() do
    GenServer.call(__MODULE__, :get_status)
  end

  def get_position() do
    GenServer.call(__MODULE__, :get_position)
  end

  def set_position(position) do
    GenServer.cast(__MODULE__, {:set_position, position})
  end

  def get_target() do
    GenServer.call(__MODULE__, :get_target)
  end

  def pick_target(position) do
    GenServer.cast(__MODULE__, {:pick_target, position})
  end

  defp pick_target([tx, ty] = target, %{position: [tx, ty]} = state) do
    %{state | status: :idle, target: target, path: nil}
  end

  defp pick_target(target, state) do
    %{state | status: :estimating, target: target, path: nil}
  end

  defp compute_path(current, tiles, %{path: %{closed_list: closed_list, open_list: open_list}} = state) do
    IO.puts("Closed list: #{ inspect closed_list }")

    neighbors =
      Astar.neighbors_of(current.position, tiles)
      |> Enum.reject(fn neighbor ->
        in_closed_list =
          closed_list
          |> Enum.any?(fn node -> node.position == neighbor.position end)

        neighbor.type != :clear or in_closed_list
      end)

    IO.puts("Rejected invalid neighbors")

    shortest_path_available =
      neighbors
      |> Enum.map(fn neighbor ->
        Astar.cost_to_enter(current.position, neighbor.position) +
        Astar.manhattan_distance(neighbor.position, state.target)
      end)
      # Avoid a weird crash when no route's available... Probably a wrong fix.
      |> Enum.min(fn -> 0 end)

    IO.puts("Calculated shortest path available")

    to_add =
      Enum.map(neighbors, fn neighbor ->
        neighbor_in_open_list =
          open_list
          |> Enum.any?(fn node -> node.position == neighbor.position end)

        g = Astar.cost_to_enter(current.position, neighbor.position)
        h = Astar.manhattan_distance(neighbor.position, state.target)
        f = g + h

        if f <= shortest_path_available or not neighbor_in_open_list do
          node = %Astar.Node{
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

  defp build_final_path(_closed_list, [ox, oy], %{parent: [ox, oy]} = _current, final_path) do
    Logger.debug("[PLAYER] Finished!")
    final_path
  end

  defp build_final_path(closed_list, origin, current, path) do
    Logger.debug("[PLAYER] Building: #{inspect current}")

    parent =
      closed_list
        |> Enum.filter(fn node -> node.position == current.parent end)
        |> List.first()

    build_final_path(closed_list, origin, parent, [parent, current] ++ path)
  end
end
