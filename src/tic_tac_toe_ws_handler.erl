-module(tic_tac_toe_ws_handler).

-behaviour(cowboy_http_websocket_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2, terminate/2]).
-export([websocket_init/3, websocket_handle/3,
        websocket_info/3, websocket_terminate/3]).

-record(state, { gid :: mpserver_types:gid() }).

init({_Any, http}, Req, []) ->
    case cowboy_http_req:header('Upgrade', Req) of
        {undefined, Req2} -> {ok, Req2, undefined};
        {<<"websocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket};
        {<<"WebSocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket}
    end.

handle(Req, State) ->
    {ok, Html} = file:read_file([code:priv_dir(mpserver), "/static/play.html"]),
    Headers = [{'Content-Type', <<"text/html">>}],
    {ok, Req2} = cowboy_http_req:reply(200, Headers, Html, Req),
    {ok, Req2, State}.

websocket_init(_TransportName, Req, _Opts) ->
    {Gid, Req} = cowboy_http_req:path(Req),
    io:format("Gid: ~p", [Gid]),
    {ok, Req, #state{gid=Gid}}.

websocket_handle({text, _Msg}, Req, State=#state{gid=_Gid}) ->
    {ok, Req, State}.
    %case erlmpc_stateless_backend:proc_bin(Msg, Conn) of
    %    {reply, Reply} -> {reply, {text, Reply}, Req, State};
    %    noreply -> {ok, Req, State}
    %end.

websocket_info({events, _Ev}, Req, State=#state{gid=_Gid}) ->
    {ok, Req, State};
    %{reply, R} =  erlmpc_stateless_backend:proc(statuscurrentsong, Conn),
    %{reply, {text, R}, Req, State};

websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

terminate(_Req, _State) -> ok.
websocket_terminate(_Reason, _Req, _State) -> ok.
