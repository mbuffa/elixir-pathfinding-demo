defmodule MoveYourCedricWeb.MapLive do
  use MoveYourCedricWeb, :live_view

  require Logger

  alias MoveYourCedric.Models.TileMap
  alias MoveYourCedric.Models.Player

  def mount(_params, _session, socket) do
    tile_map = TileMap.build()

    player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
    Player.set_position(player.position)

    socket = assign(socket, tile_map: tile_map)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Move Your Cédric</h1>

    <ul class="entities-list">
      <%= for entity <- @tile_map.entities do %>
        <li>
          <%= entity.name %> is at <%= entity.position |> List.first %> <%= entity.position |> List.last %> and is <%= phrasing_status(entity.status) %>
        </li>
      <% end %>
    </ul>

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

                <%= cond do %>
                  <% Enum.any?(@tile_map.entities, fn entity -> entity.type == "player" and entity.position == tile.position end) -> %>
                    <div class="entity entity-player">
                      <img class="cedric" src="/images/cedric_bot.png">
                    </div>
                  <% Enum.any?(@tile_map.entities, fn entity -> entity.type == "player" and entity.target == tile.position end) -> %>
                    <div class="target">&nbsp;</div>
                  <% true -> %>
                <% end %>
              </div>
            <% end) %>
          </div>
        <% end) %>
      </div>

      <div class="toolbar">
        <button phx-click="update-path">Proceed</button>
      </div>
    </main>
    """
  end

  def handle_event("update-path", _metadata, socket) do
    Player.update_path(socket.assigns.tile_map.tiles)

    {:noreply, update(socket, :tile_map, &update_map(&1))}
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

      {:noreply, update(socket, :tile_map, &update_map(&1))}
    end
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

  def phrasing_status(:idle), do: "counting turnips"
  def phrasing_status(:estimating), do: "calculating shortest path"
end
