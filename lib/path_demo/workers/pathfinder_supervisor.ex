defmodule PathDemo.Workers.PathfinderSupervisor do
  use DynamicSupervisor

  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def ensure_started(name) do
    Logger.info("[SUP] Making sure #{name} is started...")
    DynamicSupervisor.start_child(__MODULE__, {PathDemo.Workers.Pathfinder, name: name})
  end

  def get_name(socket_id) do
    id = socket_id |> String.trim("-") |> String.trim("_")
    :"Elixir.PathDemo.Workers.Pathfinder.#{id}"
  end
end
