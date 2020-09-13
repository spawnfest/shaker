defmodule(Hackney.MixProject) do
  use(Mix.Project)

  def(application()) do
    [env: env(), mod: {:hackney_app, []}, extra_applications: extra_applications()]
  end

  def(env()) do
    [
      timeout: 150_000,
      max_connections: 50,
      restart: :permanent,
      shutdown: 10000,
      maxr: 10,
      maxt: 1
    ]
  end

  def(extra_applications()) do
    [
      :crypto,
      :asn1,
      :public_key,
      :ssl,
      :idna,
      :mimerl,
      :certifi,
      :parse_trans,
      :ssl_verify_fun,
      :metrics,
      :unicode_util_compat
    ]
  end

  def(project()) do
    [
      dialyzer: dialyzer(),
      erlc_options: [:debug_info],
      version: "1.16.0",
      description: "simple HTTP client",
      package: package(),
      app: :hackney,
      language: :erlang,
      deps: deps()
    ]
  end

  def(dialyzer()) do
    [
      flags: [:race_conditions, :no_return, :unmatched_returns, :error_handling],
      plt_extra_apps: [],
      plt_location: :local,
      plt_prefix: 'hackney',
      base_plt_location: '.',
      base_plt_prefix: 'hackney'
    ]
  end

  def(package()) do
    %{
      licenses: ["Apache 2.0"],
      links: [{"Github", "https://github.com/benoitc/hackney"}],
      name: "hackney"
    }
  end

  def(deps()) do
    [
      dialyxir: "~> 1.0.0",
      idna: "6.0.1",
      mimerl: "~>1.1",
      certifi: "2.5.2",
      metrics: "1.0.1",
      parse_trans: "3.3.0",
      ssl_verify_fun: "1.1.6",
      unicode_util_compat: "0.5.0"
    ]
  end
end
