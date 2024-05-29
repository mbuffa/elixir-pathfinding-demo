defmodule PathDemo.AstarTest do
  use ExUnit.Case

  alias PathDemo.Workers.Pathfinder
  alias PathDemo.Workers.PathfinderSupervisor
  alias PathDemo.Workers.SmallMapGenerator

  setup do
    :ok = Application.ensure_started(:path_demo)
    worker_name = PathfinderSupervisor.get_name("THX-1138")
    PathfinderSupervisor.ensure_started(worker_name)
    {:ok, %{worker_name: worker_name}}
  end

  describe "algorithm" do
    test "path building and walking that path", %{worker_name: worker_name} do
      path_updates = [
        %{
          closed_list: [],
          final_path: nil,
          open_list: [%PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]}]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 0], f: 74, g: 14, h: 60, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [3, 0], f: 60, g: 10, h: 50, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [4, 0], f: 54, g: 14, h: 40, parent: [3, 1]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 0], f: 74, g: 14, h: 60, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [3, 0], f: 60, g: 10, h: 50, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [4, 0], f: 54, g: 14, h: 40, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [0, 2], f: 74, g: 14, h: 60, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 3], f: 60, g: 10, h: 50, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 4], f: 54, g: 14, h: 40, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [1, 4], f: 40, g: 10, h: 30, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 0], f: 74, g: 14, h: 60, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [3, 0], f: 60, g: 10, h: 50, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [4, 0], f: 54, g: 14, h: 40, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [0, 2], f: 74, g: 14, h: 60, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 3], f: 60, g: 10, h: 50, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 4], f: 54, g: 14, h: 40, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [1, 4], f: 40, g: 10, h: 30, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [3, 4], f: 20, g: 10, h: 10, parent: [2, 4]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [3, 4], f: 20, g: 10, h: 10, parent: [2, 4]}
          ],
          final_path: nil,
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 0], f: 74, g: 14, h: 60, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [3, 0], f: 60, g: 10, h: 50, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [4, 0], f: 54, g: 14, h: 40, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [0, 2], f: 74, g: 14, h: 60, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 3], f: 60, g: 10, h: 50, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 4], f: 54, g: 14, h: 40, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [1, 4], f: 40, g: 10, h: 30, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [4, 4], f: 10, g: 10, h: 0, parent: [3, 4]}
          ]
        },
        %{
          closed_list: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 2], f: 40, g: 10, h: 30, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [3, 1], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [3, 4], f: 20, g: 10, h: 10, parent: [2, 4]},
            %PathDemo.Astar.Node{position: [4, 4], f: 10, g: 10, h: 0, parent: [3, 4]}
          ],
          final_path: [
            %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [3, 4], f: 20, g: 10, h: 10, parent: [2, 4]},
            %PathDemo.Astar.Node{position: [4, 4], f: 10, g: 10, h: 0, parent: [3, 4]}
          ],
          open_list: [
            %PathDemo.Astar.Node{position: [1, 1], f: 74, g: 14, h: 60, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 1], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [1, 2], f: 60, g: 10, h: 50, parent: [2, 2]},
            %PathDemo.Astar.Node{position: [2, 0], f: 74, g: 14, h: 60, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [3, 0], f: 60, g: 10, h: 50, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [4, 0], f: 54, g: 14, h: 40, parent: [3, 1]},
            %PathDemo.Astar.Node{position: [0, 2], f: 74, g: 14, h: 60, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 3], f: 60, g: 10, h: 50, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [0, 4], f: 54, g: 14, h: 40, parent: [1, 3]},
            %PathDemo.Astar.Node{position: [1, 4], f: 40, g: 10, h: 30, parent: [1, 3]}
          ]
        }
      ]

      final_path = [
        %PathDemo.Astar.Node{position: [2, 2], f: 40, g: 0, h: 40, parent: [2, 2]},
        %PathDemo.Astar.Node{position: [1, 3], f: 54, g: 14, h: 40, parent: [2, 2]},
        %PathDemo.Astar.Node{position: [2, 4], f: 34, g: 14, h: 20, parent: [1, 3]},
        %PathDemo.Astar.Node{position: [3, 4], f: 20, g: 10, h: 10, parent: [2, 4]},
        %PathDemo.Astar.Node{position: [4, 4], f: 10, g: 10, h: 0, parent: [3, 4]}
      ]

      tile_map = SmallMapGenerator.build()

      player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
      Pathfinder.set_position(worker_name, player.position)

      target_position = [4, 4]

      :ok = Pathfinder.pick_target(worker_name, target_position)

      assert Pathfinder.get_path(worker_name) == nil
      assert Pathfinder.get_target(worker_name) == [4, 4]

      :ok = Pathfinder.walk_path(worker_name)

      assert Pathfinder.get_path(worker_name) == nil
      assert Pathfinder.get_target(worker_name) == [4, 4]

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 0)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 1)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 2)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 3)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 4)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 5)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 6)

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      assert Pathfinder.get_path(worker_name) == Enum.at(path_updates, 7)

      Pathfinder.get_path(worker_name)
      |> Map.fetch(:final_path)
      |> elem(1)
      |> Kernel.==(final_path)
      |> assert

      # "Moving" to the initial node.

      :ok = Pathfinder.walk_path(worker_name)
      :ok = Pathfinder.walk_path(worker_name)

      :ok = Pathfinder.walk_path(worker_name)
      assert Pathfinder.get_position(worker_name) == [2, 4]
      :ok = Pathfinder.walk_path(worker_name)
      assert Pathfinder.get_position(worker_name) == [3, 4]
      :ok = Pathfinder.walk_path(worker_name)
      assert Pathfinder.get_position(worker_name) == [4, 4]
      :ok = Pathfinder.walk_path(worker_name)
      assert Pathfinder.get_position(worker_name) == [4, 4]
    end

    test "short movements", %{worker_name: worker_name} do
      tile_map = SmallMapGenerator.build()

      player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
      Pathfinder.set_position(worker_name, player.position)

      target_position = [3, 4]
      :ok = Pathfinder.pick_target(worker_name, target_position)

      assert Pathfinder.get_path(worker_name) == nil
      assert Pathfinder.get_target(worker_name) == [3, 4]

      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)
      :ok = Pathfinder.update_path(worker_name, tile_map.tiles)

      expected_path = %{
        closed_list: [
          %PathDemo.Astar.Node{f: 30, g: 0, h: 30, parent: [2, 2], position: [2, 2]},
          %PathDemo.Astar.Node{f: 30, g: 10, h: 20, parent: [2, 2], position: [3, 2]},
          %PathDemo.Astar.Node{f: 44, g: 14, h: 30, parent: [2, 2], position: [3, 1]}
        ],
        final_path: nil,
        open_list: [
          %PathDemo.Astar.Node{f: 64, g: 14, h: 50, parent: [2, 2], position: [1, 1]},
          %PathDemo.Astar.Node{f: 50, g: 10, h: 40, parent: [2, 2], position: [2, 1]},
          %PathDemo.Astar.Node{f: 50, g: 10, h: 40, parent: [2, 2], position: [1, 2]},
          %PathDemo.Astar.Node{f: 44, g: 14, h: 30, parent: [2, 2], position: [1, 3]},
          %PathDemo.Astar.Node{f: 64, g: 14, h: 50, parent: [3, 1], position: [2, 0]},
          %PathDemo.Astar.Node{f: 50, g: 10, h: 40, parent: [3, 1], position: [3, 0]},
          %PathDemo.Astar.Node{f: 64, g: 14, h: 50, parent: [3, 1], position: [4, 0]}
        ]
      }

      assert Pathfinder.get_path(worker_name) == expected_path
    end
  end
end
