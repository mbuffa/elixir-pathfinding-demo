defmodule PathDemo.Repo do
  use Ecto.Repo,
    otp_app: :path_demo,
    adapter: Ecto.Adapters.Postgres
end
