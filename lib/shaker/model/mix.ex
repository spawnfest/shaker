defmodule Shaker.Model.Mix do
  @moduledoc """
  Every field of model (except project)
  is a keyword of clauses or just function body

  %{
    project: [
      param1: ["$anyenv": value1], #enviroment independant
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

  defstruct [
    project: [],
    application: [],
    "$errors": []
  ]

  @type envpairs :: Keyword.t()
  @type public :: Keyword.t(envpairs())
  @type t :: %__MODULE__{
          project: public(),
          application: public()
        }

  @doc """
  Like Map.update/4 but for model
  """
  @spec update(t(), atom(), (any() -> any()), any(), atom()) :: t()
  def update(model, param, fun, default \\ [], env \\ :"$anyenv")
  def update(
    %__MODULE__{application: application} = model,
    param, fun, default, env
  ) when param in @application_keys do
    %{model | application: update_for_env(application, param, fun, default, env)}
  end
  def update(%__MODULE__{project: project} = model, param, fun, default, env) do
    %{model | project: update_for_env(project, param, fun, default, env)}
  end

  @doc """
  Appends value or creates keyword for given param
  """
  @spec append(t(), atom(), atom(), any(), atom()) :: t()
  def append(model, param, key, value, env \\ :"$anyenv") do
    update(model, param, & [{key, value} | &1], [{key, value}], env)
  end

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
  def put(model, param, value, env) do
    update(model, param, fn _ -> value end, value, env)
  end

  @spec add_errors(t(), list()) :: t()
  def add_errors(%__MODULE__{"$errors": errors} = model, added_errors) do
    %{model | "$errors": added_errors ++ errors}
  end

  @spec merge_env(t(), t(), atom()) :: t()
  def merge_env(%__MODULE__{} = into, %__MODULE__{
    project:     project,
    application: application,
    "$errors":   errors,
  }, env) do
    Enum.reduce(project ++ application, into, fn {key, value}, model ->
      put(model, key, Keyword.fetch!(value, :"$anyenv"), env)
    end)
    |> add_errors(errors)
  end

  # Helpers

  @spec update_for_env(public(), atom(), (any() -> any()), any(), atom()) :: public()
  defp update_for_env(public, param, func, default, env) do
    Keyword.update(public, param, [{env, default}], &Keyword.update(&1, env, default, func))
  end
end
