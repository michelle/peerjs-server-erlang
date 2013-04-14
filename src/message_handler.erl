%% @doc PeerJS message handler.

-module(message_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init({tcp, http}, Req, Opts) ->
  {ok, Req, undefined_state}.

% Send message to peer.
handle(Req, State) ->
  { Apikey, _ } = cowboy_req:binding(key, Req),
  { Id, _ } = cowboy_req:binding(id, Req),
  Key = { Apikey, Id },
  { Token, _ } = cowboy_req:binding(token, Req),

  % TODO: pass on the message in the success case.
  case ets:lookup(tokens, Key) of
    [{ Key, Token }] -> handle_message(Req),
      {ok, Req2} = cowboy_req:reply(200, Req);
    _ -> {ok, Req2} = cowboy_req:reply(401, Req)
  end,
  {ok, Req2, State}.

terminate(Reason, Req, State) ->
  ok.

% TODO: Handle passing a message.
handle_message(Req) ->
  ok.
