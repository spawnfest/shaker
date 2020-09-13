defmodule Shaker.Parsers.RebarConfig do

  @rebar_config_file_wildcard "rebar.config"

  alias Shaker.Parsers.Common

  @spec umbrella?(project_root_path :: Path.t()) :: boolean()
  def umbrella?(project_root_path) do
    project_root_path
    |> Path.join("apps")
    |> Path.expand()
    |> File.dir?()
  end

  # def define_project_type(token, project_root) do
  #   case ConfigParser.umbrella?(project_root) do
  #     true -> Map.put(token, :project_type, :umbrella)
  #     false ->  Map.put(token, :project_type, :flat)
  #   end
  # end


  def parse(root_path) do
    case Common.read_from(root_path, @rebar_config_file_wildcard) do
      {:ok, rebar_config_keyword} -> {:ok, do_parse(rebar_config_keyword)}
      error -> error
    end
  end

  def initial_structure() do
    %{
      # Not proceeded data here
      "$errors": [],
      # def application - part goes here
      application: %{},
      # project and nested data goes here
      project: %{}
    }
  end

  def do_parse(rebar_config_keyword) do
    Enum.reduce(
      rebar_config_keyword,
      initial_structure(),
      &proceed_rebar_config_entry/2
    )
  end

  def proceed_rebar_config_entry({:alias, alias_list}, project_structure) do
    alias_list = Enum.map(
      alias_list,
      fn {alias_name, alias_resolution_list} ->
        {
          alias_name,
          Enum.map(
            alias_resolution_list,
            fn
              {provider, args} -> "#{provider} #{args}"
              provider when is_atom(provider) -> "#{provider}"
            end
          )
        }
      end
    )

    put_in(project_structure, [:project, :aliases], alias_list)
  end

  def proceed_rebar_config_entry({:erl_opts, erl_opts_list}, project_structure) do
    converted_opts = Enum.map(
      erl_opts_list,
      fn
        {:platform_define, platform, options} -> {:error, {:erl_opts, :platform_define, platform, options}}
        # Here both atom and {atom, atom} accepted
        config -> {:ok, config}
      end
    )
    project_structure
    |> put_in(
      [:project, :erlc_options],
      Keyword.get_values(converted_opts, :ok)
    )
    |> update_in(
      [:"$errors"],
      &(&1 ++ Keyword.get_values(converted_opts, :error))
    )
  end

  # ESCRIPT part
  def proceed_rebar_config_entry({:escript_main_app, app_name}, project_structure) do
    project_structure
    |> put_in([:project, :escript, :main_module], app_name)
  end
  def proceed_rebar_config_entry({:escript_name, app_name}, project_structure) do
    project_structure
    |> put_in([:project, :escript, :name], app_name)
  end
  def proceed_rebar_config_entry({:escript_incl_apps, _apps_list}, project_structure) do
    # Skiping for elixir projects
    project_structure
  end
  def proceed_rebar_config_entry({:escript_emu_args, args}, project_structure) do
    project_structure
    |> put_in([:project, :escript, :emu_args], args)
  end
  def proceed_rebar_config_entry({:escript_shebang, shebang}, project_structure) do
    project_structure
    |> put_in([:project, :escript, :shebang], shebang)
  end
  def proceed_rebar_config_entry({:escript_comment, comment}, project_structure) do
    project_structure
    |> put_in([:project, :escript, :comment], comment)
  end

  # HEX part
  def proceed_rebar_config_entry({:hex, hex_specification}, project_structure) do
    # Hex is not covered by mix file, it must be  specified separately
    # with mix tasks.
    # This should be noticed in migration guide
    project_structure
    |> update_in(
      [:"$errors"],
      &[{:hex, hex_specification} | &1]
    )
  end

  # Minimum OTP version
  def proceed_rebar_config_entry({:minimum_otp_version, _}, project_structure) do
    # is skiped for now
    project_structure
  end

  # Deps
  def proceed_rebar_config_entry({:deps, deps_list}, project_structure) do
    resolved_deps = Enum.map(
      deps_list,
      &Shaker.DepsResolver.convert/1
    )


    project_structure
    |> put_in(
      [:project, :deps],
      Keyword.get_values(resolved_deps, :ok)
    )
    |> update_in(
      [:"$errors"],
      &(&1 ++ Keyword.get_values(resolved_deps, :error))
    )
  end

  # GENERAL Case
  def proceed_rebar_config_entry(unsupported, project_structure) do
    project_structure
    |> update_in(
      [:"$errors"],
      &[unsupported | &1]
    )
  end
end
