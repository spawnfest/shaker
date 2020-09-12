defmodule Shaker.Parsers.RebarConfig do
  alias Shaker.Rebar.ConfigParser

  @spec umbrella?(project_root_path :: Path.t()) :: boolean()
  def umbrella?(project_root_path) do
    project_root_path
    |> Path.join("apps")
    |> Path.expand()
    |> File.dir?()
  end

  def define_project_type(token, project_root) do
    case ConfigParser.umbrella?(project_root) do
      true -> Map.put(token, :project_type, :umbrella)
      false ->  Map.put(token, :project_type, :flat)
    end
  end


  # def parse(root_path) do
  #   case read_rebar_config(root_path) do
  #     {:ok, app_src_data} -> {:ok, do_parse(app_src_data)}
  #     error -> error
  #   end
  # end
end
