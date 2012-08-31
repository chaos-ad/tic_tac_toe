%%% @doc Receive commands from gl_mpserver and pass them forward
-module(ws_mpserver).

-export([start_link/0]).

start_link() ->
    {ok, spawn_link(fun loop/0)}.

loop() ->
    application:set_env(gl_service, mpserver_node, self()),
    receive
        {send_message, Gid, Recipients, Msg, Args} ->
            Pids = get_recipients(Gid, Recipients),
            [Pid ! {send_message, Msg, Args} || Pid <- Pids];
        Msg ->
            lager:warning("Not implemented: ~p", [Msg])
    end,
    loop().

-spec get_recipients(gl_mpserver_types:gid(), gl_types:recipient()) -> list(pid()).
get_recipients(Gid, all) ->
    pg2:get_members({web_handler, Gid});

get_recipients(Gid, UserId) when is_binary(UserId) ->
    [global:whereis_name({web_handler, Gid, UserId})];

get_recipients(Gid, UserIds) when is_list(UserIds) ->
    lists:flatten([get_recipients(Gid, UserId) || UserId <- UserIds]).
