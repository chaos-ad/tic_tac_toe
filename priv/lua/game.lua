function init(options)
    return "ok", {
        turn=nil,
        users={},
        board={{'-','-','-'},{'-','-','-'},{'-','-','-'}}
    }, {}
end

function handle_timer(id, elapsed, state)
    return "ok", state, {}
end

function handle_timer_complete(id, elapsed, state)
    return "ok", state, {}
end

function handle_action(user, action, args, state)
    if #state.users < 2 then
        return "ok", state, {{message={recipients={user}, cmd="screw you", args=""}}}
    end

    if state.turn ~= user then
        return "ok", state, {{message={recipients={user}, cmd="screw you", args=""}}}
    end

    str = args[1]
    num = str:sub((str:find(' '))+1)
    cur = get_pos(num, state.board)
    if cur ~= '-' then
        return "ok", state, {{message={recipients={user}, cmd="screw you", args=""}}}
    end

    if user == state.users[1] then
        val = 'x'
        state.turn = state.users[2]
    else
        val = 'o'
        state.turn = state.users[1]
    end

    set_pos(val, num, state.board)
    if finished(state.board) then
        return "stop", state, {
            {message={recipients={user}, cmd="win", args=""}},
            {message={recipients={state.turn}, cmd="loose", args=""}},
            {message={recipients="all", cmd="board " .. board2string(state.board), args=""}}
        }
    else
        return "ok", state, {
            {message={recipients="all", cmd="board " .. board2string(state.board), args=""}}
        }
    end
end

function handle_user_join(user, state)
    table.insert(state.users, user)
    if #state.users == 2 then
        state.turn=state.users[1]
        return "ok", state, {{message={recipients="all", cmd="start_game", args=""}}}
    else
        return "ok", state, {}
    end
end

function handle_user_leave(user, state)
    return "ok", state, {{message={recipients="all", cmd="draw", args=""}}}
end


-----------------------------------------------------------------------------

function finished(table)
    return
        check(table[1][1], table[1][2], table[1][3]) or
        check(table[2][1], table[2][2], table[2][3]) or
        check(table[3][1], table[3][2], table[3][3]) or
        check(table[1][1], table[2][1], table[3][1]) or
        check(table[1][2], table[2][2], table[3][2]) or
        check(table[1][3], table[2][3], table[3][3]) or
        check(table[1][1], table[2][2], table[3][3]) or
        check(table[1][3], table[2][2], table[3][1])
end

function check(v1, v2, v3)
    return v1 == v2 and v2 == v3 and v3 ~= '-'
end



function board2string(table)
    return
    table[1][1] .. table[1][2] .. table[1][3] ..
    table[2][1] .. table[2][2] .. table[2][3] ..
    table[3][1] .. table[3][2] .. table[3][3]
end

function get_pos(num, table)
    row, col = get_idx(num)
    return table[row][col]
end

function set_pos(val, num, table)
    row, col = get_idx(num)
    table[row][col] = val
end

function get_idx(num)
    row = math.ceil(num / 3)
    col = num - ((row - 1) * 3)
    return row, col
end