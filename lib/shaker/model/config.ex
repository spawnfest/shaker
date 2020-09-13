defmodule Shaker.Model.Config do

  @type t :: %{{atom(), atom()} => any()}

  @spec put(t(), atom(), atom(), any()) :: t()
  def put(model, app, param, value) do
    Map.put(model, {app, param}, value)
  end

end
