defmodule Shaker do

  @moduledoc """
  Rebar to Mix migration tool

  ---

  Project description for developers:

  ### Short algorithm description

  Entrypoint: lib/mix/tasks/rebar2mix.ex
  This task parses command line arguments, detects if application is in umbrella.
  Then, for each detected application, it creates model, detects *.app.src and rebar.config
  file and fills model with values from these files.
  Then task resolves errors occured during filling with `Shaker.Errors`.
  Then, task generates quoted module with `Shaker.Generator.Mix` from filled model.
  Then task renders quoted module to file with `Shaker.Renderer`

  ### Model

  Model is a structure which contains representation of some mix project file
  It can be `mix.exs` or `config.exs` which is going to be implemented soon.
  Model contains data for each MIX_ENV and Model can manipulate it

  ### Filling

  Filling consists of parsing files with Parsers, resolving special cases with Resolvers.
  Each resolver and parser must refer to special behaviour to make further development easier.
  Our principles behind filling are minimal interaction with user and mix-style compliance.
  For example: thought we can implement overrides with creating aliases, this won't be mix-way.
  """

end
