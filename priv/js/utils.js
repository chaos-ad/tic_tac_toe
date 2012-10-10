var utils = (function(){

    function finished(table) {
        return check(table[0][0], table[0][1], table[0][2]) ||
            check(table[1][0], table[1][1], table[1][2]) ||
            check(table[2][0], table[2][1], table[2][2]) ||
            check(table[0][0], table[1][0], table[2][0]) ||
            check(table[0][1], table[1][1], table[2][1]) ||
            check(table[0][2], table[1][2], table[2][2]) ||
            check(table[0][0], table[1][1], table[2][2]) ||
            check(table[0][2], table[1][1], table[2][0]);
    };

    function check(v1, v2, v3) {
        return (v1 == v2) && (v2 == v3) && (v3 !== "-")
    };

    function draw(table) {
        for(i=0;i<3;++i) {
            for(j=0;j<3;++j) {
                if (table[i][j] == '-') {
                    return false
                }
            }
        }
        return true
    };

    function board2string(table) {
        var result = "";
        for(i=0; i<3; ++i) {
            for(j=0;j<3;++j) {
                result = result + table[i][j];
            }
        };
        return result;
    };

    function get_pos(num, table) {
        var pos = get_idx(num);
        return table[pos.row][pos.col];
    };

    function set_pos(val, num, table) {
        var pos = get_idx(num);
        table[pos.row][pos.col] = val;
    };

    function get_idx(num) {
        row = Math.ceil(num / 3);
        col = num - ((row - 1) * 3);
        return {row:row-1, col:col-1};
    };

    return {
        finished: finished,
        draw: draw,
        board2string: board2string,
        get_pos: get_pos,
        set_pos: set_pos
    };
})();