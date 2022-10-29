defmodule PathDemo.Workers.Pathfinder do
  use GenServer

  require Logger

  alias PathDemo.Astar

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

  def update_path(tiles) do
    GenServer.cast(__MODULE__, {:update_path, tiles})
  end

  def walk_path() do
    GenServer.cast(__MODULE__, :walk_path)
  end

  def get_path() do
    GenServer.call(__MODULE__, :get_path)
  end

  def get_position() do
    GenServer.call(__MODULE__, :get_position)
  end

  def get_status() do
    GenServer.call(__MODULE__, :get_status)
  end

  def get_target() do
    GenServer.call(__MODULE__, :get_target)
  end

  def set_position(position) do
    GenServer.cast(__MODULE__, {:set_position, position})
  end

  def pick_target(position) do
    GenServer.cast(__MODULE__, {:pick_target, position})
  end

  def handle_call(:get_path, _from, state) do
    {:reply, state.path, state}
  end

  def handle_call(:get_position, _from, state) do
    {:reply, state.position, state}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:get_target, _from, state) do
    {:reply, state.target, state}
  end

  def handle_cast({:set_position, position}, state) do
    Logger.debug("[PATHFINDER] Setting position to #{inspect(position)}")
    {:noreply, %{state | position: position}}
  end

  def handle_cast({:pick_target, position}, state) do
    new_state = pick_target(position, state)
    Logger.debug("[PATHFINDER] Setting target to #{inspect(new_state.target)}")
    {:noreply, new_state}
  end

  def handle_cast({:update_path, tiles}, state) do
    state = Astar.build_path(tiles, state)

    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: nil} = state) do
    Logger.debug("[PATHFINDER] Pick a target first.")
    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: nil}} = state) do
    Logger.debug("[PATHFINDER] Pick a target first.")
    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: []}} = state) do
    Logger.debug("[PATHFINDER] Reached destination.")

    state = %{state | path: nil, position: state.target, status: :idle, target: nil}

    {:noreply, state}
  end

  def handle_cast(:walk_path, %{path: %{final_path: [head | tail]}} = state) do
    Logger.debug("[PATHFINDER] Walking the path, received #{inspect(head)} and #{inspect(tail)}.")

    new_path = %{state.path | final_path: tail}

    state = %{state | path: new_path, position: head.position, status: :moving}

    {:noreply, state}
  end

  defp pick_target([tx, ty] = target, %{position: [tx, ty]} = state) do
    %{state | status: :idle, target: target, path: nil}
  end

  defp pick_target(target, state) do
    %{state | status: :estimating, target: target, path: nil}
  end
end
