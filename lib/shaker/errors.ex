defmodule Shaker.Errors do

  @moduledoc """
  Resolves occured errors
  """

  @ignore_keys ~w[plugins xref_checks xref_queries
    erl_files_first provider_hooks]a

  alias Shaker.Model.Mix, as: Model

  @spec render_until_empty(Model.t()) :: Model.t()
  def render_until_empty(%{"$errors": []} = model), do: model
  def render_until_empty(model) do
    render_until_empty(render(model))
  end

  @spec render(Model.t()) :: Model.t()
  def render(%{"$errors": errors} = model) do
    errors
    |> List.flatten()
    |> Enum.reduce(%{model | "$errors": []}, &render_one/2)
  end

  @spec render_one(any(), Model.t()) :: Model.t()
  defp render_one({:erl_opts, :platform_define, _, _}, model) do
    Mix.shell().error("Mix can't handle `platform_define`")
    model
  end
  defp render_one({:edoc_opts, _}, model) do
    Mix.shell().info("Can't add edoc")
    if Mix.shell().yes?("Add ex_doc?") do
      model
      |> Model.append(:deps, :ex_doc, "~> 0.18.0", :dev)
      |> Model.put(:docs, [])
    else
      model
    end
  end
  defp render_one({:vsn, vsn}, model) do
    Mix.shell().error("Mix can't specify versions like #{inspect vsn}")
    Mix.shell().info("Creating version 0.0.1")
    Model.put(model, :version, "0.0.1")
  end
  defp render_one(t, model) when is_tuple(t) and :erlang.element(1, t) in @ignore_keys, do: model
  defp render_one({:minimum_otp_version, _}, model) do
    Mix.shell().info("Mix doesn't support minimum otp version setting")
    model
  end
  defp render_one({:relx, _}, model) do
    Mix.shell().error("Relx releases are not supported right now")
    model
  end
  defp render_one(error, model) do
    Mix.shell().info("Error: #{inspect error, pretty: true}")
    model
  end

end
