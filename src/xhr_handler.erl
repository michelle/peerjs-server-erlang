%% @doc PeerJS XHR streaming handler.

-module(xhr_handler).
-behaviour(cowboy_loop_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

-record(state, { key, token, id, ip, req }).

% Start XHR streaming.
init({tcp, http}, Req, Opts) ->
  {ok, Req2} = cowboy_req:chunked_reply(200,
      [{<<"content-type">>, <<"application/octet-stream">>}],
      Req),
  ok = cowboy_req:chunk(util:long_string(), Req2),
  ok = cowboy_req:chunk(<<"\n">>, Req2),

  State = #state{ key = cowboy_req:binding(key, Req),
                  token = cowboy_req:binding(token, Req),
                  id = cowboy_req:binding(id, Req) },

  Key = { State#state.key, State#state.id },
  ets:insert(connections, { Key, self() }),
  ets:insert(tokens, { Key, State#state.token }),

  {loop, Req2, State}.

% Send message to client.
info(Message, Req2, State) ->
  ok = cowboy_req:chunk(Message, State#state.req),
  {loop, Req2, State}.

% Remove from ETS if this PID is in ETS.
terminate(Reason, Req2, State) ->
  Key = { State#state.key, State#state.id },
  Token = State#state.token,
  Self = self(),
  case ets:lookup(connections, Key) of
    [{ _, Self }] -> ets:delete(connections, Key);
    _ -> ok
  end,
  case ets:lookup(tokens, Key) of
    [{ _, Token }] -> ets:delete(tokens, Key);
    _ -> ok
  end.

