defmodule Shaker.Parsers.RebarConfig do

  @moduledoc """
  Parses rebar.config file
  """

  @rebar_config_file_wildcard "rebar.config"

  alias Shaker.Model.Mix, as: Model
  alias Shaker.Parsers.Common
  alias Shaker.Resolver.Deps,     as: DepsResolver
  alias Shaker.Resolver.Dialyzer, as: DialyzerResolver

  @spec umbrella?(project_root_path :: Path.t()) :: boolean()
  def umbrella?(project_root_path) do
    project_root_path
    |> Path.join("apps")
    |> Path.expand()
    |> File.dir?()
  end

  def parse(model, root_path) do
    case Common.read_from(root_path, @rebar_config_file_wildcard) do
      {:ok, rebar_config_keyword} -> do_parse(model, rebar_config_keyword)
      error -> Model.add_errors(model, [{:rebar_config, error}])
    end
  end

  def do_parse(model, rebar_config_keyword) do
    Enum.reduce(rebar_config_keyword, model, &proceed_rebar_config_entry/2)
  end

  def proceed_rebar_config_entry({:alias, alias_list}, model) do
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

  def proceed_rebar_config_entry({:erl_opts, erl_opts_list}, model) do
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
  def proceed_rebar_config_entry({:escript_main_app, main}, model) do
    Model.append(model, :escript, :main_module, main)
  end

  def proceed_rebar_config_entry({:escript_name, name}, model) do
    Model.append(model, :escript, :name, name)
  end

  def proceed_rebar_config_entry({:escript_incl_apps, _apps_list}, model) do
    # Skiping for elixir projects
    model
  end

  def proceed_rebar_config_entry({:escript_emu_args, args}, model) do
    Model.append(model, :escript, :emu_args, args)
  end

  def proceed_rebar_config_entry({:escript_shebang, shebang}, model) do
    Model.append(model, :escript, :shebang, shebang)
  end

  def proceed_rebar_config_entry({:escript_comment, comment}, model) do
    Model.append(model, :escript, :comment, comment)
  end

  # HEX part
  def proceed_rebar_config_entry({:hex, hex_specification}, model) do
    # Hex is not covered by mix file, it must be  specified separately
    # with mix tasks.
    # This should be noticed in migration guide
    Model.add_errors(model, [{:hex, hex_specification}])
  end

  # Minimum OTP version
  def proceed_rebar_config_entry({:minimum_otp_version, _}, model) do
    # FIXME is skiped for now
    model
  end

  # Deps
  def proceed_rebar_config_entry({:deps, deps_list}, model) do
    resolved_deps = Enum.map(deps_list, &DepsResolver.convert/1)

    model
    |> Model.put(:deps, Keyword.get_values(resolved_deps, :ok))
    |> Model.add_errors(Keyword.get_values(resolved_deps, :error))
  end

  #Dialyzer
  def proceed_rebar_config_entry({:dialyzer, dialyzer_list}, model) do
    resolved_dialyzer = Enum.map(dialyzer_list, &DialyzerResolver.convert/1)

    model
    |> Model.put(:dialyzer, Keyword.get_values(resolved_dialyzer, :ok))
    |> Model.add_errors(Keyword.get_values(resolved_dialyzer, :error))
  end

  #Profiles
  def proceed_rebar_config_entry({:profiles, profiles}, model) do
    Enum.reduce(profiles, model, fn {env, config}, model ->
      other = do_parse(%Model{}, config)
      Model.merge_env(model, other, env)
    end)
  end

  # GENERAL Case
  def proceed_rebar_config_entry(unsupported, model) do
    Model.add_errors(model, [unsupported])
  end
end
