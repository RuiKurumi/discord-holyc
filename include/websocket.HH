#ifndef WEBSOCKET_HH
#define WEBSOCKET_HH

#include "tls.HH"

class WebSocket
{
    TLSContext *tls;
    Bool connected;


    U8 *host;
    U8 *path;
};


class WebSocketFrame
{
    U8 opcode;

    U64 payload_length;

    U8 *payload;
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

Bool DecodeWebSocketFrame(
    U8 *buffer,
    I64 length,
    WebSocketFrame *frame
);

I64 GatewayHeartbeat(
    WebSocket *ws,
    I64 sequence
);

U0 WebSocketClose(
    WebSocket *ws
);

#endif