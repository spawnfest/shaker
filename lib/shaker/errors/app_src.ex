defmodule Shaker.Errors do

  def render(errors) do
    Enum.each(errors, fn error ->
      IO.inspect error, label: :error
    end)
  end

end
