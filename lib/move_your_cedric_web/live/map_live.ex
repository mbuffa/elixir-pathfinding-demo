defmodule MoveYourCedricWeb.MapLive do
  use MoveYourCedricWeb, :live_view

  alias MoveYourCedric.Models.TileMap

  def mount(_params, _session, socket) do
    socket = assign(socket, map: TileMap.build())
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Move Your Cédric</h1>

    <ul class="entities-list">
      <%= for entity <- @map.entities do %>
        <li>
          <%= entity.name %> is at <%= entity.position |> List.first %> <%= entity.position |> List.last %>
        </li>
      <% end %>
    </ul>

    <div class="tile_map">
      <%= Enum.map(@map.tiles, fn row -> %>
        <div class="row">
          <%= Enum.map(row, fn tile -> %>
            <div class="tile tile-<%= Atom.to_string(tile.type) %>">
              <%= if Enum.any?(@map.entities, fn entity -> entity.type == "player" and entity.position == tile.position end) do %>
                <div class="entity entity-player"></div>
              <% end %>
            </div>
          <% end) %>
        </div>
      <% end) %>
    </div>
    """
  end
end
