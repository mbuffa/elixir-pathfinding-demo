defmodule MoveYourCedric.Models.TileMap do
  defstruct [
    size: [0, 0],
    tiles: [],
    entities: []
  ]

  alias MoveYourCedric.Models.Tile
  alias MoveYourCedric.Models.Entity

  defmodule Randomizer do
    defmodule Fake do
      def tile_type_from_coords(x, y) do
        if x == 4 and y != 3 and y != 4 do
          :wall
        else
          :clear
        end
      end
    end
  end

  def build(width \\ 8, height \\ 5) do
    %__MODULE__{
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
      position: [1, 2],
      status: MoveYourCedric.Models.Pathfinder.get_status(),
      target: MoveYourCedric.Models.Pathfinder.get_target()
    }
  end
end
