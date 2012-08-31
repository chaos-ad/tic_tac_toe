-module(tic_tac_toe_game).

-behaviour(gen_gamelogic).

-export
([
    init/1,
    handle_user_join/2,
    handle_user_leave/2,
    handle_action/4,
    handle_timer/3,
    handle_timer_complete/3
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(LUA_MODULE, "lua/game.lua").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-record(state, {callback, gamestate, lua_pid}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


init(Args) ->
    lager:debug("~p: init called", [?MODULE]),
    Callback = proplists:get_value(callback, Args),
    GameArgs = proplists:delete(callback, Args),
    LuaModule = filename:join(priv_dir(), ?LUA_MODULE),

    {ok, LuaPid} = moon:start_vm(),
    ok = moon:load(LuaPid, LuaModule),
    {ok, Response} = moon:call(LuaPid, "init", [GameArgs]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    State = #state{callback=Callback, lua_pid=LuaPid},
    handle_response(Response, State).

handle_user_join(UserID, State=#state{gamestate=_GameState, lua_pid=LuaPid}) ->
    lager:debug("~p: handle_user_join: userid=~p", [?MODULE, UserID]),
    {ok, Response} = moon:call(LuaPid, "handle_user_join", [UserID]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    handle_response(Response, State).

handle_user_leave(UserID, State=#state{gamestate=_GameState, lua_pid=LuaPid}) ->
    lager:debug("~p: handle_user_join: userid=~p", [?MODULE, UserID]),
    {ok, Response} = moon:call(LuaPid, "handle_user_leave", [UserID]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    handle_response(Response, State).

handle_action(UserID, Action, Args, State=#state{gamestate=_GameState, lua_pid=LuaPid}) ->
    lager:debug("~p: handle_action: action=~p, userid=~p", [?MODULE, Action, UserID]),
    {ok, Response} = moon:call(LuaPid, "handle_action", [UserID, Action, Args]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    handle_response(Response, State).

handle_timer(ID, Elapsed, State=#state{gamestate=_GameState, lua_pid=LuaPid}) ->
    lager:debug("~p: handle_timer: id=~p, elapsed=~p", [?MODULE, ID, Elapsed]),
    {ok, Response} = moon:call(LuaPid, "handle_timer", [ID, Elapsed]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    handle_response(Response, State).

handle_timer_complete(ID, Elapsed, State=#state{gamestate=_GameState, lua_pid=LuaPid}) ->
    lager:debug("~p: handle_timer_complete: id=~p, elapsed=~p", [?MODULE, ID, Elapsed]),
    {ok, Response} = moon:call(LuaPid, "handle_timer_complete", [ID, Elapsed]),
%     lager:debug("~p: lua response: ~p", [?MODULE, Response]),
    handle_response(Response, State).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_response({<<"stop">>, GameState, Actions}, State) ->
    {stop, State#state{gamestate=GameState}, map_actions(Actions)};

handle_response({<<"ok">>, GameState, Actions}, State) ->
    {ok, State#state{gamestate=GameState}, map_actions(Actions)}.

map_actions(List) ->
    {_,Actions} = lists:unzip(List),
    proplists:delete(undefined, lists:map(fun map_action/1, Actions)).

map_action([{<<"start_timer">>, [
        {<<"id">>, ID},
        {<<"duration">>, Duration},
        {<<"repeats">>,Repeats} ]}])
        when is_binary(ID) andalso
             is_integer(Duration) andalso
             is_integer(Repeats) orelse is_binary(Repeats) ->
    {start_timer, {ID, Duration, map_repeats(Repeats)}};

map_action([{<<"stop_timer">>, [{<<"id">>, ID}]}]) when is_binary(ID) ->
    {stop_timer, ID};

map_action([{<<"kick_player">>, [{<<"userid">>, ID}]}]) when is_binary(ID) ->
    {kick_player, ID};

map_action([{<<"message">>, [
        {<<"recipients">>, Recipients},
        {<<"cmd">>, Cmd},
        {<<"args">>, Args}]}])
        when is_list(Recipients) orelse
             is_binary(Recipients) andalso
             is_binary(Cmd) andalso
             is_binary(Args) ->
    {message, {map_recipients(Recipients), Cmd, Args}};

map_action(Action) ->
    lager:warning("~p: improper action skipped: ~p", [?MODULE, Action]),
    undefined.

map_repeats(<<"infinity">>) -> infinity;
map_repeats(Repeats) when is_integer(Repeats) -> Repeats.

map_recipients(<<"all">>) -> all;
map_recipients(UserID) when is_binary(UserID) -> UserID;
map_recipients(UserIDList) when is_list(UserIDList) ->
    element(2, lists:unzip(UserIDList)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

priv_dir() ->
    case code:priv_dir(gl_wrapper_lua) of
        PrivDir when is_list(PrivDir) ->
            PrivDir;
        {error, bad_name} ->
            Ebin = filename:dirname(code:which(?MODULE)),
            filename:join(filename:dirname(Ebin), "priv")
    end.