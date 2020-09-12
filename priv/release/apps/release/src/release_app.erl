%%%-------------------------------------------------------------------
%% @doc release public API
%% @end
%%%-------------------------------------------------------------------

-module(release_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    release_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
