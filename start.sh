#!/bin/sh
rebar get-deps compile
erl -pa ebin deps/*/ebin -s peerjs \
    -eval "io:format(\"Point your browser at http://localhost:8080/ to use a simple websocket client~n\")."

