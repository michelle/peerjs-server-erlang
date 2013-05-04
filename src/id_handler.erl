%% @doc PeerJS ID delegator.

-module(id_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init({tcp, http}, Req, Opts) ->
  {ok, Req, undefined_state}.

% Send message to peer.
handle(Req, State) ->
  Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET,OPTIONS">>, Req),
  Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),

  {ok, Req3} = handle_others(Req2),
  {ok, Req3, State}.

handle_others(Req) ->
  Id = util:get_random_string(16, "abcdefghijklmnopqrstuvwxyz0123456789"),
  cowboy_req:reply(200, [], Id, Req).

terminate(Reason, Req, State) ->
  ok.
