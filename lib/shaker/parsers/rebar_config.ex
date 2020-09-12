defmodule Shaker.Parsers.RebarConfig do

  @rebar_config_file_wildcard "**/*.erl"

  import Shaker.Parsers.Common

  @spec umbrella?(project_root_path :: Path.t()) :: boolean()
  def umbrella?(project_root_path) do
    project_root_path
    |> Path.join("apps")
    |> Path.expand()
    |> File.dir?()
  end

  #def define_project_type(token, project_root) do
    #case ConfigParser.umbrella?(project_root) do
      #true -> Map.put(token, :project_type, :umbrella)
      #false ->  Map.put(token, :project_type, :flat)
    #end
  #end

  def parse(root_path) do
    case read_from(root_path, @rebar_config_file_wildcard) do
      {:ok, data} -> {:ok, data}
      error -> error
    end
  end


  # def parse(root_path) do
  #   case read_rebar_config(root_path) do
  #     {:ok, app_src_data} -> {:ok, do_parse(app_src_data)}
  #     error -> error
  #   end
  # end
end
