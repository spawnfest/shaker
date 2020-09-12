defmodule Shaker.Model.Mix do

  @moduledoc """
  Every field of model (except project)
  is a keyword of clauses or just function body

  %{
    project: [
      param1: ["$any": value1], #enviroment independant
      param2: [test: value1, dev: value2]
    ],
    application: [
      param1: ["$any": value1],
      ...
    ]
  }
  """

  @application_keys ~w(extra_applications registered env
    applications mod start_phases included_application maxT)a

  defstruct [project: [], application: []]

  @type envpairs :: Keyword.t()
  @type public :: Keyword.t(envpairs())
  @type t :: %__MODULE__{
    project:     public(),
    application: public()
  }

  @doc """
  Same as `put/4` but for multiple values at once
  """
  @spec put_pairs(t(), Keyword.t() | %{atom() => any()}, any()) :: t()
  def put_pairs(model, pairs, env \\ :"$anyenv") do
    Enum.reduce(pairs, model, fn {k, v}, model -> put(model, k, v, env) end)
  end

  @doc """
  Puts value into model for given param
  """
  @spec put(t(), atom(), any(), any()) :: t()
  def put(model, param, value, env \\ :"$anyenv")
  def put(model, _, [], _), do: model
  def put(
    %__MODULE__{application: application} = model,
    param, value, env
  ) when param in @application_keys do
    %{model | application: put_for_env(application, param, value, env)}
  end
  def put(%__MODULE__{project: project} = model, param, value, env) do
    %{model | project: put_for_env(project, param, value, env)}
  end

  @spec put_for_env(public(), atom(), any(), atom()) :: public()
  defp put_for_env(public, param, value, env) do
    Keyword.update(public, param, [{env, value}], & Keyword.put(&1, env, value))
  end

end
