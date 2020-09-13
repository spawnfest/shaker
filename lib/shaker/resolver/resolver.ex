defmodule Shaker.Resolver do

  @moduledoc "Behaviour for Options Resolvers"

  @doc """
  Resolves data and returns resolved data or error
  """
  @callback convert(any()) :: {:ok, {atom(), any()}} | {:error, any()}

end
