MpServer = new Object();

MpServer.init = function() {
    if ("WebSocket" in window) {
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
    // Ask for current song, volume and status
    //MpServer.ws.send("{ \"statuscurrentsong\": true }");
    MpServer.ok("Socket opened");
};

MpServer.onclose = function(evt) {
    //MpServer.stop_freq();
    MpServer.err("Disconnected");
};

MpServer.onmessage = function(evt) {
    MpServer.ok("Got message!");
    // We accept only one kind of message: json statuscurrentsong
    //var json = JSON.parse(evt.data);
    //MpServer.update_screen(json);
};

MpServer.onerror = function(evt) {
    MpServer.err("Error in websockets!");
    console.log(evt.data);
};

MpServer.ok = function(msg) {
    $("#status").removeClass().addClass("ok").html(msg); };
MpServer.err = function(msg) {
    $("#status").removeClass().addClass("error").html(msg); };

$(function() {
    MpServer.init();
});
