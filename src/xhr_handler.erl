%% @doc PeerJS XHR handler.

-module(xhr_handler).
-behaviour(cowboy_loop_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

-record(state, { key, token, id, ip, action }).

init({tcp, http}, Req, Opts) ->
    {ok, Req2} = cowboy_req:chunked_reply(200,
        [{<<"content-type">>, <<"application/octet-stream">>}],
        Req),
    ok = cowboy_req:chunk(util:long_string()),
    State = #state{ key = cowboy_req:binding(key, Req),
                    req = Req2,
                    token = cowboy_req:binding(token, Req),
                    id = cowboy_req:binding(id, Req),
                    action = cowboy_req:binding(action, Req) },
    {loop, Req, State}.

info(Message, Req, State) ->
    {ok, Req2} = cowboy_req:reply(200, [], <<"Hello World!">>, Req),
    {ok, Req2, State}.

terminate(Reason, Req, State) ->
    ok.
