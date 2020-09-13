defmodule Shaker.Options do
  @option_parser_params [
    strict: [
      apps_root: :string,
      in_umbrella: :boolean
    ]
  ]

  @default_params %{
    in_umbrella: false
  }

  def parse(args) do
    case OptionParser.parse(args, @option_parser_params) do
      {parsed_params, [], []} ->
        {:ok, Map.merge(@default_params, Enum.into(parsed_params, %{}))}
      _ -> {:error, :bad_params}
    end
  end
end
