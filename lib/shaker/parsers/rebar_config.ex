defmodule Shaker.Parsers.RebarConfig do

  @moduledoc """
  Parses rebar.config file
  """

  @behaviour Shaker.Parsers

  @rebar_config_file_wildcard "rebar.config"

  alias Shaker.Model.Mix, as: Model
  alias Shaker.Parsers.Common
  alias Shaker.Resolver.Deps,     as: DepsResolver
  alias Shaker.Resolver.Dialyzer, as: DialyzerResolver

  def parse(model, root_path) do
    case Common.read_from(root_path, @rebar_config_file_wildcard) do
      {:ok, rebar_config_keyword} -> do_parse(model, rebar_config_keyword)
      error -> Model.add_errors(model, [{:rebar_config, error}])
    end
  end

  defp do_parse(model, rebar_config_keyword) do
    Enum.reduce(rebar_config_keyword, model, &proceed_rebar_config_entry/2)
  end

  defp proceed_rebar_config_entry({:alias, alias_list}, model) do
    alias_list =
      Enum.map(alias_list, fn {alias_name, alias_resolution_list} ->
        {
          alias_name,
          Enum.map(alias_resolution_list, fn
            {provider, args} -> "#{provider} #{args}"
            provider when is_atom(provider) -> "#{provider}"
          end)
        }
      end)

    Model.put(model, :aliases, alias_list)
  end

  defp proceed_rebar_config_entry({:erl_opts, erl_opts_list}, model) do
    converted_opts =
      Enum.map(erl_opts_list, fn
        {:platform_define, platform, options} ->
          {:error, [{:erl_opts, :platform_define, platform, options}]}

        # Here both atom and {atom, atom} accepted
        config ->
          {:ok, config}
      end)

    model
    |> Model.put(:erlc_options, Keyword.get_values(converted_opts, :ok))
    |> Model.add_errors(Keyword.get_values(converted_opts, :error))
  end

  # ESCRIPT part
  defp proceed_rebar_config_entry({:escript_main_app, main}, model) do
    Model.append(model, :escript, :main_module, main)
  end

  defp proceed_rebar_config_entry({:escript_name, name}, model) do
    Model.append(model, :escript, :name, name)
  end

  defp proceed_rebar_config_entry({:escript_incl_apps, _apps_list}, model) do
    # Skiping for elixir projects
    model
  end

  defp proceed_rebar_config_entry({:escript_emu_args, args}, model) do
    Model.append(model, :escript, :emu_args, args)
  end

  defp proceed_rebar_config_entry({:escript_shebang, shebang}, model) do
    Model.append(model, :escript, :shebang, shebang)
  end

  defp proceed_rebar_config_entry({:escript_comment, comment}, model) do
    Model.append(model, :escript, :comment, comment)
  end

  # HEX part
  defp proceed_rebar_config_entry({:hex, hex_specification}, model) do
    # Hex is not covered by mix file, it must be  specified separately
    # with mix tasks.
    # This should be noticed in migration guide
    Model.add_errors(model, [{:hex, hex_specification}])
  end

  # Minimum OTP version
  defp proceed_rebar_config_entry({:minimum_otp_version, _} = pair, model) do
    Model.add_errors(model, [pair])
  end

  # Deps
  defp proceed_rebar_config_entry({:deps, deps_list}, model) do
    resolve_with(model, :deps, deps_list, &DepsResolver.convert/1)
  end

  #Dialyzer
  defp proceed_rebar_config_entry({:dialyzer, dialyzer_list}, model) do
    resolve_with(model, :dialyzer, dialyzer_list, &DialyzerResolver.convert/1)
  end

  #Profiles
  defp proceed_rebar_config_entry({:profiles, profiles}, model) do
    Enum.reduce(profiles, model, fn {env, config}, model ->
      other = do_parse(%Model{}, config)
      Model.merge_env(model, other, env)
    end)
  end

  ### Tests

  # Eunit
  defp proceed_rebar_config_entry({:eunit_opts, opts}, model) do
    model
    |> Model.append(:deps, :mix_eunit, "~> 0.2", :test)
    |> Model.append(:preffered_cli_env, :eunit, :test)
    |> Model.put(:eunit, [verbose: Keyword.has_key?(opts, :verbose)])
  end

  #Common test
  defp proceed_rebar_config_entry({k, _}, model
  ) when k in ~w[ct_first_files ct_otps ct_readable]a do
    model
    |> Model.append(:deps, :ctex, "~> 0.1", :test)
    |> Model.append(:preffered_cli_env, :ct, :test)
  end

  #Elvis
  defp proceed_rebar_config_entry({:elvis, conf}, model) do
    model
    |> Model.put(:elvis, conf)
    |> Model.append(:deps, :mix_elvis, "~> 0.1", :test)
    |> Model.append(:deps, :mix_elvis, "~> 0.1", :dev)
  end

  # GENERAL Case
  defp proceed_rebar_config_entry(unsupported, model) do
    Model.add_errors(model, [unsupported])
  end

  # Helpers

  defp resolve_with(model, key, keyword, function) do
    resolved = Enum.map(keyword, function)
    model
    |> Model.put(key, Keyword.get_values(resolved, :ok))
    |> Model.add_errors(Keyword.get_values(resolved, :error))
  end
end
