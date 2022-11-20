defmodule PathDemoWeb.Plugs.AllowIframe do
  def init(options), do: options

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("x-frame-options", "ALLOW-FROM 127.0.0.1 https://mbuffa.github.io/")
  end
end
