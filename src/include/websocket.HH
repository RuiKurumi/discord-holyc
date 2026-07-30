#ifndef WEBSOCKET_HH
#define WEBSOCKET_HH

#include "tls.HH"

class WebSocket
{
    TLSContext *tls;
    Bool connected;
};


WebSocket *WebSocketConnect(
    U8 *host,
    U8 *path
);

I64 WebSocketSend(
    WebSocket *ws,
    U8 *data,
    I64 length
);

I64 WebSocketReceive(
    WebSocket *ws,
    U8 *buffer,
    I64 length
);

U0 WebSocketClose(
    WebSocket *ws
);

#endif