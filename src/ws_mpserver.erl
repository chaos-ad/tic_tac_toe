%%% @doc Receive commands from gl_mpserver and pass them forward
-module(ws_mpserver).

-export([start_link/0, init/1]).

start_link() ->
    proc_lib:start_link(?MODULE, init, [self()]).

init(Parent) ->
    proc_lib:init_ack(Parent, {ok, self()}),
    application:set_env(gl_service, mpserver_node, self()),
    loop().

loop() ->
    receive
        {send_message, Gid, Recipients, Msg, Args} ->
            Pids = get_recipients(Gid, Recipients),
            [Pid ! {send_message, Msg, Args} || Pid <- Pids];
        Msg ->
            lager:warning("Not implemented: ~p", [Msg])
    end,
    loop().

-spec get_recipients(gl_mpserver_types:gid(), gl_types:recipient()) -> list(pid()).
get_recipients(Gid, Rcpt) ->
    lists:filter(fun(X) -> X =/= undefined end, do_get_recipients(Gid, Rcpt)).

do_get_recipients(Gid, all) ->
    case pg2:get_members({web_handler, Gid}) of
        Pids when is_list(Pids) -> Pids;
        {error, _} -> []
    end;

do_get_recipients(Gid, UserId) when is_binary(UserId) ->
    [global:whereis_name({web_handler, Gid, UserId})];

do_get_recipients(Gid, UserIds) when is_list(UserIds) ->
    lists:flatten([do_get_recipients(Gid, UserId) || UserId <- UserIds]).
