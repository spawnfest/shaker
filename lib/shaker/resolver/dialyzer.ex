defmodule Shaker.Resolver.Dialyzer do

  @moduledoc """
  Module to convert Dialyzer config to Dialyxir config
  """

  @bad_configs ~w[plt_apps]a

  def convert({:warnings, warnings}) do
    {:ok, {:flags, warnings}}
  end

  def convert({key, _} = pair) when key not in @bad_configs do
    {:ok, pair}
  end

  def convert({key, _}) do
    {:error, {:bad_dialyzer_key, key}}
  end

end
