-module(tic_tac_toe_ws_handler).

-behaviour(cowboy_http_websocket_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2, terminate/2]).
-export([websocket_init/3, websocket_handle/3,
        websocket_info/3, websocket_terminate/3]).

-record(state, {
        gid :: gl_mpserver_types:gid(),
        userid :: gl_mpserver_types:userid()
    }).

init({_Any, http}, Req, []) ->
    case cowboy_http_req:header('Upgrade', Req) of
        {undefined, Req2} -> {ok, Req2, undefined};
        {<<"websocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket};
        {<<"WebSocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket}
    end.

handle(Req, State) ->
    {ok, Html} = file:read_file([tic_tac_toe_helpers:priv_dir_path(tic_tac_toe),
            "/static/play.html"]),
    Headers = [{'Content-Type', <<"text/html">>}],
    {ok, Req2} = cowboy_http_req:reply(200, Headers, Html, Req),
    {ok, Req2, State}.

websocket_init(_TransportName, Req, _Opts) ->
    {[<<"play">>, Gid, UserId], Req} = cowboy_http_req:path(Req),

    pg2:create({web_handler, Gid}),
    case lists:member(self(), pg2:get_members({web_handler, Gid})) of
        false -> pg2:join({web_handler, Gid}, self());
        true -> ok
    end,

    global:register_name({web_handler, Gid, UserId}, self()),

    case global:whereis_name({glm, Gid}) of
        undefined ->
            gl_control:start_game_instance(Gid);
        _ ->
            ok
    end,

    gl_control:user_join(Gid, UserId),
    {ok, Req, #state{gid=Gid, userid=UserId}}.

%% @doc User sent a message
%%
%% For this MpServer we support only 1 type of message.
%% Get a message and pass it directly to GL with message_id=1.
websocket_handle({text, Msg}, Req, State=#state{gid=Gid, userid=Uid}) ->
    gl_control:send_actions(Gid, Uid, [{<<"front_msg">>, Msg}]),
    {ok, Req, State}.

websocket_info({send_message, Msg, _Args}, Req, State) ->
    {reply, {text, Msg}, Req, State};

websocket_info(stop_game, Req, State) ->
    {reply, {text, <<"stop_game">>}, Req, State}.

websocket_terminate(_Reason, _Req, #state{gid=Gid, userid=UserId}) ->
    gl_control:user_leave(Gid, UserId).

terminate(_Req, _State) -> ok.
