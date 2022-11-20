defmodule PathDemoWeb.MapLive do
  use PathDemoWeb, :live_view

  require Logger

  alias PathDemo.Workers.{
    Pathfinder,
    PathfinderSupervisor,
    SmallMapGenerator,
    ComplexMapGenerator
  }

  defp worker_name(socket) do
    PathfinderSupervisor.get_name(socket.id)
  end

  def mount(params, _session, socket) do
    worker_name = worker_name(socket)
    PathfinderSupervisor.ensure_started(worker_name)

    map_type = Map.get(params, "map", "small")

    tile_map = case map_type do
      "small" ->
        SmallMapGenerator.build(12, 12)
      "complex" ->
        ComplexMapGenerator.build()
    end

    player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
    Pathfinder.set_position(worker_name, player.position)

    socket =
      assign(socket,
        tile_map: tile_map,
        path: Pathfinder.get_path(worker_name),
        player_position: Pathfinder.get_position(worker_name),
        player_target: Pathfinder.get_target(worker_name)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h3>Pathfinding A* Live Demo</h3>

    <div class="tilemap-container">
      <div class="toolbar">
        <button phx-click="update-path" <%= update_disable(assigns)%>>Find the path</button>
        <button phx-click="walk-path" <%= walk_disable(assigns) %>>Walk the path</button>
        <p><%= if is_nil(assigns.player_target), do: "Pick a target!", else: "" %></p>
      </div>

      <ul class="entities-list">
        <%= for entity <- @tile_map.entities do %>
          <li>
            <%= entity.name %> is at <%= entity.position |> List.first %> <%= entity.position |> List.last %> and is <%= phrasing_status(entity.status) %>
          </li>
        <% end %>
      </ul>

      <div class="tile_map">
        <%= Enum.map(@tile_map.tiles, fn row -> %>
          <div class="row">
            <%= Enum.map(row, fn tile -> %>
              <div
                class="tile tile-<%= Atom.to_string(tile.type) %>"
                phx-click="click-tile"
                phx-value-position-x="<%= tile.position |> List.first %>"
                phx-value-position-y="<%= tile.position |> List.last %>"
              >
                <span class="tile-position">
                  <%= display_tile_position(tile.position) %>
                </span>
                <%= cond do %>
                  <% tile_has_player?(@player_position, tile.position) -> %>
                    <div class="entity entity-player">
                      <span>🤖</span>
                    </div>
                  <% tile_is_target?(@player_target, tile.position) -> %>
                    <div class="target">
                      <span>👀</span>
                    </div>
                  <% tile_in_final_path?(@path, tile.position) -> %>
                    <div class="path">
                      <span>🦶</span>
                    </div>
                  <% tile_in_open_list?(@path, tile.position) -> %>
                    <div class="open_list">
                      <div class="info-container">
                        <span class="span-g">
                          <%= get_tile_node(@path.open_list, tile.position).g %>
                        </span>
                        <span class="span-h">
                          <%= get_tile_node(@path.open_list, tile.position).h %>
                        </span>
                        <span class="span-f">
                          <%= get_tile_node(@path.open_list, tile.position).f %>
                        </span>
                      </div>
                    </div>
                  <% tile_in_closed_list?(@path, tile.position) -> %>
                    <div class="closed_list">
                      <div class="info-container">
                        <span class="span-g">
                          <%= get_tile_node(@path.closed_list, tile.position).g %>
                        </span>
                        <span class="span-h">
                          <%= get_tile_node(@path.closed_list, tile.position).h %>
                        </span>
                        <span class="span-f">
                          <%= get_tile_node(@path.closed_list, tile.position).f %>
                        </span>
                      </div>
                    </div>
                  <% Atom.to_string(tile.type) == "wall" -> %>
                    <div class="tile-wall">&nbsp;</div>
                  <% true -> %>
                <% end %>
              </div>
            <% end) %>
          </div>
        <% end) %>
      </div>
    </div>
    """
  end

  def handle_event("update-path", _metadata, socket) do
    worker_name = worker_name(socket)
    Pathfinder.update_path(worker_name, socket.assigns.tile_map.tiles)

    socket = update(socket, :tile_map, &update_map_entities(&1, worker_name))
    socket = assign(socket, :path, Pathfinder.get_path(worker_name))
    socket = assign(socket, :player_position, Pathfinder.get_position(worker_name))

    {:noreply, socket}
  end

  def handle_event("click-tile", %{"position-x" => x, "position-y" => y}, socket) do
    worker_name = worker_name(socket)
    position = [x |> String.to_integer(), y |> String.to_integer()]

    target =
      socket.assigns.tile_map.tiles
      |> List.flatten()
      |> Enum.find(fn tile -> tile.position == position end)

    if target.type == :wall do
      {:noreply, socket}
    else
      :ok = Pathfinder.pick_target(worker_name, position)

      socket = update(socket, :tile_map, &update_map_entities(&1, worker_name))
      socket = assign(socket, :path, Pathfinder.get_path(worker_name))
      socket = assign(socket, :player_target, Pathfinder.get_target(worker_name))

      {:noreply, socket}
    end
  end

  def handle_event("walk-path", _metadata, socket) do
    worker_name = worker_name(socket)
    Pathfinder.walk_path(worker_name)

    socket = update(socket, :tile_map, &update_map_entities(&1, worker_name))
    socket = assign(socket, :path, Pathfinder.get_path(worker_name))
    socket = assign(socket, :player_position, Pathfinder.get_position(worker_name))
    socket = assign(socket, :player_target, Pathfinder.get_target(worker_name))

    {:noreply, socket}
  end

  defp update_map_entities(tile_map, worker_name) do
    updated_entities =
      tile_map.entities
      |> Enum.map(fn entity ->
        if entity.type == "player" do
          %{
            entity
            | position: Pathfinder.get_position(worker_name),
              status: Pathfinder.get_status(worker_name),
              target: Pathfinder.get_target(worker_name)
          }
        else
          entity
        end
      end)

    tile_map |> Map.put(:entities, updated_entities)
  end

  def phrasing_status(:idle), do: "idle"
  def phrasing_status(:estimating), do: "calculating the shortest path to take"
  def phrasing_status(:moving), do: "moving"

  def display_tile_position(position) do
    [x, y] = position
    "#{x}; #{y}"
  end

  def get_tile_node(list, position) do
    list |> Enum.find(fn node -> position == node.position end)
  end

  def tile_has_player?([x, y], [x, y]), do: true
  def tile_has_player?(_, _), do: false

  def tile_is_target?(nil, _), do: false
  def tile_is_target?([x, y], [x, y]), do: true
  def tile_is_target?(_, _), do: false

  def tile_in_final_path?(nil, _), do: false
  def tile_in_final_path?(%{final_path: nil}, _), do: false
  def tile_in_final_path?(%{final_path: []}, _), do: false
  def tile_in_final_path?(%{final_path: final_path}, position) do
    final_path |> Enum.any?(fn node -> node.position == position end)
  end

  def tile_in_open_list?(nil, _), do: false
  def tile_in_open_list?(%{open_list: nil}, _), do: false
  def tile_in_open_list?(%{open_list: []}, _), do: false
  def tile_in_open_list?(%{open_list: open_list}, position) do
    open_list |> Enum.any?(fn node -> node.position == position end)
  end

  def tile_in_closed_list?(nil, _), do: false
  def tile_in_closed_list?(%{closed_list: nil}, _), do: false
  def tile_in_closed_list?(%{closed_list: []}, _), do: false
  def tile_in_closed_list?(%{closed_list: closed_list}, position) do
    closed_list |> Enum.any?(fn node -> node.position == position end)
  end

  defp update_disable(%{path: %{final_path: final_path}, player_target: player_target} = _assigns) do
    if is_nil(player_target) or not is_nil(final_path) do
      "disabled"
    else
      ""
    end
  end
  defp update_disable(%{player_target: nil}), do: "disabled"
  defp update_disable(_), do: ""

  defp walk_disable(%{path: %{final_path: nil}} = _assigns), do: "disabled"
  defp walk_disable(%{path: nil} = _assigns), do: "disabled"
  defp walk_disable(_), do: ""
end
