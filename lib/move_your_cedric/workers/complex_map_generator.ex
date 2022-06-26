defmodule MoveYourCedric.Workers.ComplexMapGenerator do
  alias MoveYourCedric.Models.Entity
  alias MoveYourCedric.Models.Tile
  alias MoveYourCedric.Models.TileMap

  defmodule Randomizer do
    defmodule Fake do
      @walls [
        [1, 4],
        [2, 4],
        [3, 4],
        [4, 4],
        [5, 4],
        [6, 4],
        [1, 2],
        [1, 3],
        [1, 4],
        [1, 5],
        [1, 6],
        [6, 2],
        [6, 3],
        [6, 4],
        [6, 5],
        [6, 6]
      ]

      def tile_type_from_coords(x, y) do
        if Enum.any?(@walls, fn pos -> pos == [x, y] end) do
          :wall
        else
          :clear
        end
      end
    end
  end

  @player_start_position [4, 9]

  def build(width \\ 8, height \\ 12) do
    %TileMap{
      size: [width, height],
      tiles: build_tiles(width, height),
      entities: build_entities(width, height)
    }
  end

  defp build_tiles(width, height) do
    Enum.map(1..height, fn y ->
      Enum.map(1..width, fn x ->
        %Tile{
          position: [x - 1, y - 1],
          type: Randomizer.Fake.tile_type_from_coords(x - 1, y - 1)
        }
      end)
    end)
  end

  defp build_entities(_width, _height) do
    [
      scaffold_player()
    ]
  end

  defp scaffold_player() do
    %Entity{
      type: "player",
      name: "Cédric",
      position: @player_start_position,
      status: MoveYourCedric.Workers.Pathfinder.get_status(),
      target: MoveYourCedric.Workers.Pathfinder.get_target()
    }
  end
end
