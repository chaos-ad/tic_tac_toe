MpServer = new Object();

MpServer.init = function() {
    if ("WebSocket" in window) {
        MpServer.h = {};
        MpServer.h.wsUri = document.URL.replace(/^http:/, "ws:");
        MpServer.ws = new WebSocket(MpServer.h.wsUri);
        MpServer.ws.onopen = MpServer.onopen;
        MpServer.ws.onclose = MpServer.onclose;
        MpServer.ws.onmessage = MpServer.onmessage;
        MpServer.ws.onerror = MpServer.onerror;
    } else {
        alert("Your browser does not support websockets, sorry");
        return false;
    }
};

MpServer.onopen = function(evt) {
    MpServer.ok("Socket opened");
};

MpServer.onclose = function(evt) {
    MpServer.err("Disconnected");
};

MpServer.onmessage = function(evt) {
    var msg = evt.data;
    var match;
    if (match = msg.match(/board ([xo-]{9})/)) {
        board.update(match[1]);
    } else if (msg == "won") {
        MpServer.ok("You won! Congratulations!");
    } else if (msg == "lost") {
        MpServer.err("You lost! Loser!");
    } else if (msg == "draw") {
        MpServer.err("Draw! Nice game, pal!");
    }
    else MpServer.stat(msg);
};

MpServer.onerror = function(evt) {
    MpServer.err("Error in websockets!");
    console.log(evt.data);
};

MpServer.ok = function(msg) {
    $("#status").prepend($('<div class="ok">' + msg + '</div>')); };
MpServer.err = function(msg) {
    $("#status").prepend($('<div class="error">' + msg + '</div>')); };
MpServer.stat = function(msg) {
    $("#status").prepend($('<div class="stat">' + msg + '</div>')); };


$(function() {
    MpServer.init();
    board = new Board($("#board"));
});

function Board(obj) {
    this.obj = obj; // JS object
    var i = 1;
    obj.find("td").each(function() {
            $(this).data({"i" : i++});
    });
    obj.on("click", "td", function() {
            MpServer.ws.send("click " + $(this).data("i"));
    });
}

Board.prototype.update = function(b) {
    var i = 0;
    this.obj.find("td").each(function() {
            $(this).html(b[i] == '-' ? '' : b[i]);
            i++;
    });
};
