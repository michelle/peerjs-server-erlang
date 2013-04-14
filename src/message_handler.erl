%% @doc PeerJS message handler.

-module(message_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init({tcp, http}, Req, Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  { Method, _ } = cowboy_req:method(Req),
  Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>,
    <<"GET,OPTIONS,POST">>, Req),
  Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>,
    <<"*">>, Req1),
  Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>,
    <<"content-type">>, Req2),
  {ok, Req4} = handle_others(Req3, Method),
  {ok, Req4, State}.

handle_others(Req, <<"OPTIONS">>) ->
  cowboy_req:reply(200, Req);

% Send message to peer.
handle_others(Req, _) ->
  { Apikey, _ } = cowboy_req:binding(key, Req),
  { Id, _ } = cowboy_req:binding(id, Req),
  Key = { Apikey, Id },
  { Token, _ } = cowboy_req:binding(token, Req),

  case ets:lookup(tokens, Key) of
    [{ _, Token }] -> {ok, Req2} = handle_message(Apikey, Id, Req);
    _ -> {ok, Req2} = cowboy_req:reply(401, Req)
  end,
  {ok, Req2}.

terminate(Reason, Req, State) ->
  ok.

% TODO: Handle passing a message.
handle_message(Apikey, Id, Req) ->
  { ok, Body, _ } = cowboy_req:body(Req),
  { struct, Original } = mochijson2:decode(Body),
  PeerId = proplists:get_value(<<"dst">>, Original),
  Message = mochijson2:encode({ struct, [{ <<"src">>, Id } | Original] }),
  Peer = { Apikey, PeerId },

  case ets:lookup(connections, Peer) of
    [{ _, Process }] ->
      Process ! Message,
      Error = { struct, [{ <<"type">>, <<"HTTP-ERROR">> }] },
      {ok, Req2} = cowboy_req:reply(200, [], mochijson2:encode(Error), Req);
    _ -> {ok, Req2} = cowboy_req:reply(200, Req)
  end,
  {ok, Req2}.
