defmodule Meme.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Meme.Worker.start_link(arg1, arg2, arg3)
      # worker(Meme.Worker, [arg1, arg2, arg3]),
      Supervisor.child_spec(build_cache(), id: :meme)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Meme.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_cache do
    cachex_version = Application.spec(:cachex, :vsn) 
    opts = [name: :meme]

    extra_opts =
      if Version.match?(cachex_version, "~> 4.0")do
        import Cachex.Spec, only: [router: 1]

        [
          router: router(module: Cachex.Router.Ring),
          options: [
            limit: 10_000,
            policy: :lru,
            stats: true
          ]
        ]
      else
        []
      end

    {Cachex, Keyword.merge(opts, extra_opts)}
  end
end
