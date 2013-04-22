%% @doc PeerJS XHR streaming handler.

-module(xhr_handler).
-behaviour(cowboy_loop_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

-record(state, { key, token, id, ip, req }).

% Start XHR streaming.
init({tcp, http}, Req, Opts) ->
  Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET,OPTIONS">>, Req),
  Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),

  handle_others(Req2).

handle_others(Req) ->
  { Apikey, _ } = cowboy_req:binding(key, Req),
  { Token, _ } = cowboy_req:binding(token, Req),
  { Id, _ } = cowboy_req:binding(id, Req),
  State = #state{ key = Apikey,
                  token = Token,
                  id = Id },

  Key = { State#state.key, State#state.id },
  % TODO: reply with ID-TAKEN or something.
  case ets:lookup(connections, Key) of
    { Key, _ } -> cowboy_req:reply(401, Req);
    _ -> ets:insert(connections, { Key, self() }),
      ets:insert(tokens, { Key, State#state.token }),
      {loop, start_chunking(Req), State}
  end.

handle_options(Req) ->
  Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET,OPTIONS">>, Req),
  Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
  {ok, Req2}.

% Begin the chunking process with a buffer.
start_chunking(Req) ->
  {ok, Req2} = cowboy_req:chunked_reply(200,
      [{<<"content-type">>, <<"application/octet-stream">>}],
      Req),
  ok = cowboy_req:chunk(util:long_string(), Req2),
  ok = cowboy_req:chunk(<<"\n">>, Req2),
  % TODO: only send for first stream.
  Restart = cowboy_req:qs_val(<<0>>, Req),
  case Restart of
    <<0>> ->
      ok = cowboy_req:chunk(mochijson2:encode({struct, [{ <<"type">>, <<"OPEN">> }]}), Req2),
      ok = cowboy_req:chunk(<<"\n">>, Req2);
    _ ->
      ok
  end,
  Req2.

% Send message to client.
info(Message, Req2, State) ->
  ok = cowboy_req:chunk(Message, Req2),
  ok = cowboy_req:chunk(<<"\n">>, Req2),
  {loop, Req2, State}.

% Remove from ETS if this PID is in ETS.
terminate(Reason, Req2, State) ->
  Key = { State#state.key, State#state.id },
  Token = State#state.token,
  Self = self(),
  case ets:lookup(connections, Key) of
    [{ _, Self }] -> ets:delete(connections, Key);
    _ -> ok
  end.

