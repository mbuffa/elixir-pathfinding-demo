defmodule MoveYourCedric.AstarTest do
  use MoveYourCedric.DataCase

  alias MoveYourCedric.Workers.Pathfinder
  alias MoveYourCedric.Workers.SmallMapGenerator

  describe "algorithm" do
    test "simple assertions" do
      path_updates = [
        %{
          closed_list: [],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{
              f: 60,
              g: 0,
              h: 60,
              parent: [1, 2],
              position: [1, 2]
            }
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [3, 2], position: [3, 3]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [3, 2], position: [3, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [4, 3], position: [5, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [4, 3], position: [3, 4]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [4, 3], position: [4, 4]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [4, 3], position: [5, 4]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]}
          ],
          final_path: nil,
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [3, 2], position: [3, 3]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [4, 3], position: [5, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [4, 3], position: [3, 4]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [4, 3], position: [4, 4]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [4, 3], position: [5, 4]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [5, 1]},
            %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [6, 2]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [5, 2], position: [6, 3]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]},
            %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]}
          ],
          final_path: [
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]},
            %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]}
          ],
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [3, 2], position: [3, 3]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [4, 3], position: [5, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [4, 3], position: [3, 4]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [4, 3], position: [4, 4]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [4, 3], position: [5, 4]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [5, 1]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [6, 2]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [5, 2], position: [6, 3]}
          ]
        },
        %{
          closed_list: [
            %MoveYourCedric.Astar.Node{f: 60, g: 0, h: 60, parent: [1, 2], position: [1, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [2, 1], position: [3, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 0]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]},
            %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]}
          ],
          final_path: [
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [1, 2], position: [2, 1]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [2, 1], position: [3, 2]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [3, 2], position: [4, 3]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [4, 3], position: [5, 2]},
            %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]}
          ],
          open_list: [
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [0, 1]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [1, 1]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [0, 2]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [1, 2], position: [2, 2]},
            %MoveYourCedric.Astar.Node{f: 94, g: 14, h: 80, parent: [1, 2], position: [0, 3]},
            %MoveYourCedric.Astar.Node{f: 80, g: 10, h: 70, parent: [1, 2], position: [1, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [1, 2], position: [2, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [2, 1], position: [1, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [2, 1], position: [2, 0]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [3, 2], position: [3, 3]},
            %MoveYourCedric.Astar.Node{f: 40, g: 10, h: 30, parent: [4, 3], position: [5, 3]},
            %MoveYourCedric.Astar.Node{f: 74, g: 14, h: 60, parent: [4, 3], position: [3, 4]},
            %MoveYourCedric.Astar.Node{f: 60, g: 10, h: 50, parent: [4, 3], position: [4, 4]},
            %MoveYourCedric.Astar.Node{f: 54, g: 14, h: 40, parent: [4, 3], position: [5, 4]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [5, 1]},
            %MoveYourCedric.Astar.Node{f: 20, g: 10, h: 10, parent: [5, 2], position: [6, 2]},
            %MoveYourCedric.Astar.Node{f: 34, g: 14, h: 20, parent: [5, 2], position: [6, 3]}
          ]
        }
      ]

      final_path = [
        %MoveYourCedric.Astar.Node{
          f: 54,
          g: 14,
          h: 40,
          parent: [1, 2],
          position: [2, 1]
        },
        %MoveYourCedric.Astar.Node{
          f: 54,
          g: 14,
          h: 40,
          parent: [2, 1],
          position: [3, 2]
        },
        %MoveYourCedric.Astar.Node{
          f: 54,
          g: 14,
          h: 40,
          parent: [3, 2],
          position: [4, 3]
        },
        %MoveYourCedric.Astar.Node{
          f: 34,
          g: 14,
          h: 20,
          parent: [4, 3],
          position: [5, 2]
        },
        %MoveYourCedric.Astar.Node{f: 14, g: 14, h: 0, parent: [5, 2], position: [6, 1]}
      ]

      Application.ensure_started(:move_your_cedric)

      tile_map = SmallMapGenerator.build()

      player = tile_map.entities |> Enum.find(fn entity -> entity.type == "player" end)
      Pathfinder.set_position(player.position)

      target_position = [6, 1]

      :ok = Pathfinder.pick_target(target_position)

      assert Pathfinder.get_path() == nil
      assert Pathfinder.get_target() == [6, 1]

      :ok = Pathfinder.walk_path()

      assert Pathfinder.get_path() == nil
      assert Pathfinder.get_target() == [6, 1]

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 0)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 1)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 2)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 3)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 4)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 5)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 6)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 7)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 8)

      :ok = Pathfinder.update_path(tile_map.tiles)
      assert Pathfinder.get_path() == Enum.at(path_updates, 9)

      Pathfinder.get_path()
      |> Map.fetch(:final_path)
      |> elem(1)
      |> Kernel.==(final_path)
      |> assert

      # "Moving" to the initial node.
      :ok = Pathfinder.walk_path()

      :ok = Pathfinder.walk_path()
      assert Pathfinder.get_position() == [3, 2]
      :ok = Pathfinder.walk_path()
      assert Pathfinder.get_position() == [4, 3]
      :ok = Pathfinder.walk_path()
      assert Pathfinder.get_position() == [5, 2]
      :ok = Pathfinder.walk_path()
      assert Pathfinder.get_position() == [6, 1]
    end
  end
end
