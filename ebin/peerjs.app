{application,peerjs,
             [{description,"PeerJS Cloud Server."},
              {vsn,"1"},
              {modules,[message_handler,message_sup,peerjs,peerjs_app,util,
                        websocket_sup,ws_handler,xhr_handler,xhr_sup]},
              {registered,[]},
              {applications,[kernel,stdlib,cowboy]},
              {mod,{peerjs_app,[]}},
              {env,[]}]}.
