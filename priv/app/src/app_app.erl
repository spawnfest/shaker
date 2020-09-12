%%%-------------------------------------------------------------------
%% @doc app public API
%% @end
%%%-------------------------------------------------------------------

-module(app_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    app_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
