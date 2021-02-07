defmodule MoveYourCedricWeb.MapLive do
  use MoveYourCedricWeb, :live_view

  require Logger

  alias MoveYourCedric.Models.TileMap
  alias MoveYourCedric.Models.Player

  def mount(_params, _session, socket) do
    tile_map = TileMap.build()

    player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
    Player.set_position(player.position)

    socket = assign(socket,
      tile_map: tile_map,
      path: Player.get_path(),
      player_position: Player.get_position(),
      player_target: Player.get_target()
    )
    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect assigns

    ~L"""
    <h1>Move Your Cédric</h1>

    <div class="tilemap-container">
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
                      <img class="cedric" src="/images/cedric_bot.png">
                    </div>
                  <% tile_is_target?(@player_target, tile.position) -> %>
                    <div class="target">&nbsp;</div>
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

      <div class="toolbar">
        <img class="morpheus" src="/images/morpheus.jpg">
        <button phx-click="update-path">Find the path</button>
        <button phx-click="walk-path">Walk the path</button>

        <ul class="entities-list">
          <%= for entity <- @tile_map.entities do %>
            <li>
              <%= entity.name %> is at <%= entity.position |> List.first %> <%= entity.position |> List.last %> and is <%= phrasing_status(entity.status) %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("update-path", _metadata, socket) do
    Player.update_path(socket.assigns.tile_map.tiles)

    socket = update(socket, :tile_map, &update_map(&1))
    socket = assign(socket, :path, Player.get_path())
    socket = assign(socket, :player_position, Player.get_position())

    {:noreply, socket}
  end

  def handle_event("click-tile", %{"position-x" => x, "position-y" => y}, socket) do
    position = [x |> String.to_integer(), y |> String.to_integer()]

    target =
      socket.assigns.tile_map.tiles
      |> List.flatten()
      |> Enum.find(fn tile -> tile.position == position end)

    if target.type == :wall do
      {:noreply, socket}
    else
      :ok = Player.pick_target(position)

      socket = update(socket, :tile_map, &update_map(&1))
      socket = assign(socket, :path, Player.get_path())
      socket = assign(socket, :player_target, Player.get_target())

      {:noreply, socket}
    end
  end

  def handle_event("walk-path", _metadata, socket) do
    Player.walk_path()

    socket = update(socket, :tile_map, &update_map(&1))
    socket = assign(socket, :path, Player.get_path())
    socket = assign(socket, :player_position, Player.get_position())
    socket = assign(socket, :player_target, Player.get_target())

    {:noreply, socket}
  end

  defp update_map(tile_map) do
    updated_entities =
      tile_map.entities
      |> Enum.map(fn entity ->
        if entity.type == "player" do
          %{entity | position: Player.get_position(),
                     status: Player.get_status(),
                     target: Player.get_target()
          }
        else
          entity
        end
      end)

    tile_map =
      tile_map
      |> Map.put(:entities, updated_entities)

    tile_map
  end

  def phrasing_status(:idle), do: "counting gold pieces"
  def phrasing_status(:estimating), do: "calculating shortest path to go farm"
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
end
