function init(options) {
    return {
        result: "ok",
        state: {
            turn: 0,
            players: [],
            board: [['-','-','-'],['-','-','-'],['-','-','-']]
        },
        actions: [
        ]
    };
}

function handle_timer(timer_id, elapsed, state) {
    return {result: "ok", state: state, actions: []};
}

function handle_timer_complete(timer_id, elapsed, state) {
    return {result: "ok", state: state, actions: []};
}

function handle_action(player_id, action, args, state) {

    if (state.players.length < 2) {
        return {result: "ok", state: state, actions: [utils.message([player_id], "screw you")]};
    }

    if (state.turn !== player_id) {
        return {result: "ok", state: state, actions: [utils.message([player_id], "screw you")]};
    }

    var val;
    var str = args[0];
    var num = str.substr(str.search(" ")+1);
    var cur = get_pos(num, state.board)
    if (cur !== '-') {
        return {result: "ok", state: state, actions: [utils.message([player_id], "screw you")]};
    }

    if (player_id == state.players[0]) {
        val = 'x'
        state.turn = state.players[1]
    } else {
        val = 'o'
        state.turn = state.players[0]
    }

    set_pos(val, num, state.board)
    if (finished(state.board)) {
        state.board=[['-','-','-'],['-','-','-'],['-','-','-']]
        return {result: "ok", state: state, actions: [
            utils.message([player_id], "win"),
            utils.message([state.turn], "loose"),
            utils.broadcast("board " + board2string(state.board))
        ]};
    } else if (draw(state.board)) {
        state.board=[['-','-','-'],['-','-','-'],['-','-','-']]
        return {result: "ok", state: state, actions: [
            utils.message([player_id], "draw"),
            utils.message([state.turn], "draw"),
            utils.broadcast("board " + board2string(state.board))
        ]};
    } else {
        return {result: "ok", state: state, actions: [
            utils.broadcast("board " + board2string(state.board))
        ]};
    }
}

function handle_user_join(player_id, state) {
    if (state.players.push(player_id) == 2) {
        state.turn = state.players[0];
        return {result: "ok", state: state, actions: [
            utils.broadcast("start_game")
        ]};
    } else {
        return {result: "ok", state: state, actions: []};
    }
}

function handle_user_leave(player_id, state) {
    return {result: "ok", state: state, actions: [
        utils.broadcast("draw"),
        utils.broadcast("stop_game")
    ]};
}

/////////////////////////////////////////////////////////////////////////////

function finished(table) {
    return check(table[0][0], table[0][1], table[0][2]) ||
           check(table[1][0], table[1][1], table[1][2]) ||
           check(table[2][0], table[2][1], table[2][2]) ||
           check(table[0][0], table[1][0], table[2][0]) ||
           check(table[0][1], table[1][1], table[2][1]) ||
           check(table[0][2], table[1][2], table[2][2]) ||
           check(table[0][0], table[1][1], table[2][2]) ||
           check(table[0][2], table[1][1], table[2][0]);
}

function check(v1, v2, v3) {
    return (v1 == v2) && (v2 == v3) && (v3 !== "-")
}

function draw(table) {
    for(i=0;i<3;++i) {
        for(j=0;j<3;++j) {
            if (table[i][j] == '-') {
                return false
            }
        }
    }
    return true
}

function board2string(table) {
    var result = "";
    for(i=0; i<3; ++i) {
        for(j=0;j<3;++j) {
            result = result + table[i][j];
        }
    };
    return result;
}

function get_pos(num, table) {
    var pos = get_idx(num);
    return table[pos.row][pos.col];
}

function set_pos(val, num, table) {
    var pos = get_idx(num);
    table[pos.row][pos.col] = val;
}

function get_idx(num) {
    row = Math.ceil(num / 3);
    col = num - ((row - 1) * 3);
    return {row:row-1, col:col-1};
}
