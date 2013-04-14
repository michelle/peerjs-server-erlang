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
  Key = { cowboy_req:binding(key, Req), cowboy_req:binding(id, Req) },
  Token = cowboy_req:binding(token, Req),

  % TODO: pass on the message in the success case.
  case ets:lookup(tokens, Key) of
    { Key, Token } -> handle_message(Req), cowboy_req:reply(200, Req);
    _ -> cowboy_req:reply(401, Req)
  end.

terminate(Reason, Req, State) ->
  ok.

% TODO: Handle passing a message.
handle_message(Req) ->
  ok.
