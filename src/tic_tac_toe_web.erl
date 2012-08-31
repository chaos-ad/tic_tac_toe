-module(tic_tac_toe_web).
-export([start_link/0]).

start_link() ->
    Dispatch = [
        {'_', [
                {[<<"static">>, '...'], cowboy_http_static,
                    [{directory, {priv_dir, tic_tac_toe, [<<"static">>]}}]},
                {[<<"play">>, '_', '_'], tic_tac_toe_ws_handler, []}
            ]
        }
    ],

    {ok, ListenPort} = application:get_env(tic_tac_toe, listen_port),

    cowboy:start_listener(tic_tac_toe_ws_handler, 2,
        cowboy_tcp_transport, [{port, ListenPort}],
        cowboy_http_protocol, [{dispatch, Dispatch}]
    ).

