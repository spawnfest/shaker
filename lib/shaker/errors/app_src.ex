defmodule Shaker.Errors.AppSrc do
  def render({key, value}) do
    "`#{key}` record is not possible to proceed. Please, check it manualy. Defined values are: #{
      inspect(value)
    }"
  end
end
