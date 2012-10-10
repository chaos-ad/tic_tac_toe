function init(options) {
    console.log("init called");
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
    console.log("handle_timer called");
    return {result: "ok", state: state, actions: []};
}

function handle_timer_complete(timer_id, elapsed, state) {
    console.log("handle_timer_complete called");
    return {result: "ok", state: state, actions: []};
}

function handle_action(player_id, action, args, state) {
    console.log("handle_action called");
    if (state.players.length < 2) {
        return {result: "ok", state: state, actions: [actions.message([player_id], "screw you")]};
    }

    if (state.turn !== player_id) {
        return {result: "ok", state: state, actions: [actions.message([player_id], "screw you")]};
    }

    var val;
    var str = args[0];
    var num = str.substr(str.search(" ")+1);
    var cur = utils.get_pos(num, state.board)
    if (cur !== '-') {
        return {result: "ok", state: state, actions: [actions.message([player_id], "screw you")]};
    }

    if (player_id == state.players[0]) {
        val = 'x'
        state.turn = state.players[1]
    } else {
        val = 'o'
        state.turn = state.players[0]
    }

    utils.set_pos(val, num, state.board)
    if (utils.finished(state.board)) {
        state.board=[['-','-','-'],['-','-','-'],['-','-','-']]
        return {result: "ok", state: state, actions: [
            actions.message([player_id], "win"),
            actions.message([state.turn], "loose"),
            actions.broadcast("board " + utils.board2string(state.board))
        ]};
    } else if (utils.draw(state.board)) {
        state.board=[['-','-','-'],['-','-','-'],['-','-','-']]
        return {result: "ok", state: state, actions: [
            actions.message([player_id], "draw"),
            actions.message([state.turn], "draw"),
            actions.broadcast("board " + utils.board2string(state.board))
        ]};
    } else {
        return {result: "ok", state: state, actions: [
            actions.broadcast("board " + utils.board2string(state.board))
        ]};
    }
}

function handle_user_join(player_id, state) {
    console.log("handle_user_join called");
    if (state.players.push(player_id) == 2) {
        state.turn = state.players[0];
        return {result: "ok", state: state, actions: [
            actions.broadcast("start_game")
        ]};
    } else {
        return {result: "ok", state: state, actions: []};
    }
}

function handle_user_leave(player_id, state) {
    console.log("handle_user_leave called");
    return {result: "ok", state: state, actions: [
        actions.broadcast("draw"),
        actions.broadcast("stop_game")
    ]};
}

/////////////////////////////////////////////////////////////////////////////
