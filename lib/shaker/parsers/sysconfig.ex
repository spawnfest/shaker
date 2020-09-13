defmodule Shaker.Parsers.Sysconfig do

  @moduledoc """
  Parser to parse sys.config into config model
  """

  @behaviour Shaker.Parsers

  alias Shaker.Model.Config, as: Model

  def parse(model, path_to_sys_config) do
    case :file.consult(path_to_sys_config) do
      {:ok, config} -> do_parse(model, config)
      error -> Mix.raise inspect(error)
    end
  end

  def do_parse(model, [config]) do
    Enum.reduce(
      config,
      model,
      &proceed_sys_config_entry/2
    )
  end

  defp proceed_sys_config_entry({app, app_cfg}, model) do
    Enum.reduce(app_cfg, model, fn {param, value}, model ->
      Model.put(model, app, param, value)
    end)
  end

end
