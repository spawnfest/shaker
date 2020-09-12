defmodule Shaker.Parsers.AppSrc do
  @app_src_file_wildcard "**/*.app.src"
  @autoloaded_erlang_applications MapSet.new([:kernel, :stdlib, :elixir])

  def parse(root_path) do
    case read_app_src(root_path) do
      {:ok, app_src_data} -> do_parse(app_src_data)
      error -> error
    end
  end

  def read_app_src(root_path) do
    with [path_to_app_src] <-
           Path.wildcard(Path.join(root_path, @app_src_file_wildcard)) |> IO.inspect(),
         {:ok, [{:application, app_name, app_keyword}]} <-
           :file.consult(path_to_app_src) |> IO.inspect() do
      {:ok, {app_name, app_keyword}}
    else
      _ -> {:error, :bad_file}
    end
  end

  def do_parse({app_name, app_keyword}) do
    initial_structure = %{
      '$errors': [],
      application: %{},
      project: %{
        app: app_name,
        package: %{
          name: :erlang.atom_to_binary(app_name)
        }
      }
    }

    Enum.reduce(
      app_keyword,
      initial_structure,
      &proceed_app_src_entry/2
    )
  end

  def proceed_app_src_entry({:description, description}, project_structure) do
    put_in(
      project_structure,
      [:project, :description],
      :erlang.list_to_binary(description)
    )
  end
  def proceed_app_src_entry({:vsn, version}, project_structure) do
    put_in(
      project_structure,
      [:project, :version],
      :erlang.list_to_binary(version)
    )
  end
  def proceed_app_src_entry({:mod, mod}, project_structure) do
    # Mod goes as-is - basically it's a tuple
    put_in(
      project_structure,
      [:application, :mod],
      mod
    )
  end
  def proceed_app_src_entry({:applications, apps}, project_structure) do
    # applications in mix are defined as extra_applications
    put_in(
      project_structure,
      [:application, :extra_applications],
      apps
      |> MapSet.new()
      |> MapSet.difference(@autoloaded_erlang_applications)
      |> Enum.into([])
    )
  end
  def proceed_app_src_entry({:env, env}, project_structure) do
    # env goes inside application data
    put_in(
      project_structure,
      [:application, :env],
      env
    )
  end
  def proceed_app_src_entry({:licenses, licenses}, project_structure) do
    # licenses goes inside project's package data
    put_in(
      project_structure,
      [:project, :package, :licenses],
      licenses
      |> Enum.map(&:erlang.list_to_binary/1)
    )
  end
  def proceed_app_src_entry({:links, links}, project_structure) do
    # links goes inside project's package data
    put_in(
      project_structure,
      [:project, :package, :links],
      links
    )
  end


  # Registered goes here - it's skipped
  def proceed_app_src_entry({:registered, _}, acc), do: acc
  # Modules goes here - it's skipped
  def proceed_app_src_entry({:modules, _}, acc), do: acc

  # Default case - something is not known for the Shaker. Warn the user here
  def proceed_app_src_entry({key, data}, acc) do
    update_in(acc, [:"$errors"], &[{key, data} | &1])
  end
end
