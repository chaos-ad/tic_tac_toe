-module(tic_tac_toe_sup).
-behaviour(supervisor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([start_link/0, init/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(CHILD(I), {I, {I, start_link, []}, permanent, 60000, worker, [I]}).
-define(CHILD(I, Args), {I, {I, start_link, Args}, permanent, 60000, worker, [I]}).
-define(CHILD(I, Args, Role), {I, {I, start_link, Args}, permanent, 60000, Role, [I]}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init([]) ->
    start_webserver(),
    {ok, { {one_for_one, 5, 10}, [
        ?CHILD(ws_mpserver)
    ]} }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_webserver() ->
    {ok, ListenPort} = application:get_env(tic_tac_toe, listen_port),
    {ok, _} = cowboy:start_listener(tic_tac_toe_ws_handler, 2,
        cowboy_tcp_transport, [{port, ListenPort}],
        cowboy_http_protocol, [{dispatch, dispatch()}]
    ).

dispatch() ->
    [
        {'_', [
                {[<<"static">>, '...'], cowboy_http_static,
                    [
                        {directory, {priv_dir, tic_tac_toe, [<<"static">>]}},
                        {mimetypes, [
                            {<<".html">>, [<<"text/html">>]},
                            {<<".js">>, [<<"application/javascript">>]}
                        ]}
                    ]},
                {[<<"play">>, '_', '_'], tic_tac_toe_ws_handler, []}
            ]
        }
    ].
