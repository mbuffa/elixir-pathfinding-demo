defmodule PathDemo.Workers.SmallMapGenerator do
  alias PathDemo.Models.Entity
  alias PathDemo.Models.Tile
  alias PathDemo.Models.TileMap

  @player_start_position [2, 2]

  defmodule Randomizer do
    defmodule Fake do
      @walls [
        [2, 3],
        [3, 3],
        [4, 3],
        [4, 2],
        [4, 1],
        [5, 1],
        [4, 6],
        [5, 0],
        [0, 5],
        [1, 5],
        [2, 5],
        [2, 6],
        [4, 5],
        [6, 5],
        [6, 4],
        [3, 6],
        [3, 7],
        [3, 8],
        [5, 8],
        [6, 7],
        [7, 7],
        [8, 7],
        [8, 6],
        [1, 9],
        [2, 10],
        [3, 11],
        [6, 8],
        [8, 4],
        [8, 3],
        [8, 2],
        [8, 1],
        [8, 0],
        [8, 10],
        [8, 9],
        [9, 9],
        [9, 8],
        [9, 7],
        [10, 1],
        [11, 2]
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

  def build(width \\ 8, height \\ 5) do
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
      name: "Robby",
      position: @player_start_position,
      status: :idle,
      target: nil
    }
  end
end
