%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(peerjs_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% MACROS
-define(XHR_PORT, 9000).

%% API.
start(_Type, _Args) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/:key/:id/:token/:action", xhr_handler, []},
      {"/peerjs", ws_handler, []}
    ]}
  ]),
  {ok, _} = cowboy:start_http(peerjs, 100, [{port, ?XHR_PORT}],
    [{env, [{dispatch, Dispatch}]}]),
  websocket_sup:start_link(),
  xhr_sup:start_link().

stop(_State) ->
  ok.
