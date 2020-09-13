# Shaker

**Shaker** - CLI tool, that automates migrations from `Rebar3` into `Mix` for Erlang projects of any kind. It supports:

* Applications
* Libraries
* Escripts
* Releases (not yet)
* Erlang test-lint tools support (`eunit`, `ct`, `elvis`)
* Any other tools you can imagine as an Erlang project

## The problem

While **Mix** tools is perfect for both `Erlang` and `Elixir` projects, it's not so much distributed inside  `Erlang`'s world. One of the main reasons - severity of migration **allready existing** projects from one package manager into another.

This process *can* and *must* be automated. **Shaker** tries to eliminate this gap.

## Quick start

Project is made in a form of a `mix archive`, which can be simply installed from **Hex**:

```bash
$ mix archive.install hex shaker
```

This installation brings to a user a new `mix` command:

```bash
$ mix rebar2mix
```

This command must be executed inside any valid **Rebar3** project, with next effects:

1. An interactive process of `mix project` generation starts
1. During the process user can be prompted to choose different options and configurations
1. After the process is finished - `mix project` artifacts are created in the manner, when the project itself is ready
  to run inside a `mix` package management tool.


For example

```bash
$ mix deps.get
$ iex -S mix
$ mix test
$ mix compile
$ mix deps.get
```

will be available to run as in a standart `mix` project.

## Roadmap

1. Improve the code quality - making refactoring, adding more tests, docs and specs
2. Implementing more and more uncovered `Rebar3` features, untill full coverage.
3. Relx
4. `sys.config`
5. Overrides handling

## Contributions

Project is stiall in an active development phase so feel free to submit any Issues or Pull requests!
