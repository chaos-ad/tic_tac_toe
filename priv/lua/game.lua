function init(Options)
    return "ok", {players=Options.players, duration=Options.round_time}, {
        {start_timer={id="test", duration=2000, repeats=2}},
        {start_timer={id="update", duration=5000, repeats="infinity"}},
        {start_timer={id="broadcast", duration=10000, repeats=3}}
    }
end

function handle_timer(Id, Elapsed, State)
    if (Id ~= "update") then
        Actions = {}
    else
        Actions = {{stop_timer={id="update"}}}
    end
    return "ok", State, Actions
end


function handle_timer_complete(Id, Elapsed, State)
    if (Id == "broadcast") then
        Actions = {}
    else
        Actions = {}
    end
    return "ok", State, Actions
end


function handle_action(User, Action, Args, State)
    return "ok", State, {}
end


function handle_user_join(User, State)
    return "ok", State, {}
end


function handle_user_leave(User, State)
    return "ok", State, {}
end

