defmodule MoveYourCedric.Repo do
  use Ecto.Repo,
    otp_app: :move_your_cedric,
    adapter: Ecto.Adapters.Postgres
end
