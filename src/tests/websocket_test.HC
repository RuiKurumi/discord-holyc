#include "../include/websocket.HH"
#include "../net/socket_linux.HC"
#include "../net/tls_openssl.HC"
#include "../net/websocket.HC"
#include "../include/print.HH"
#include "../runtime/string.HC"

I32 Main(I32 argc, U8 **argv)
{
    WebSocket *ws;

    ws = WebSocketConnect(
    "gateway.discord.gg",
    "/?v=10&encoding=json"
    );

    if(!ws)
    {
        Print("Connection failed\n");
         Print("ws is NULL\n");
        return 1;
    }
    else
    {
        Print("ws is not NULL\n");
    }
    Print("TLSConnect returned\n");

    if(!ws->tls)
    {
        Print("TLS is NULL\n");
        Free(ws);
        return NULL;
    }

    Print("TLS is valid\n");
    Print("Returning WebSocket\n");
    Print("WebSocket object created\n");


    I64 sent;
    sent = WebSocketSend(
        ws,
        "{\"op\":1,\"d\":null}",
        15
    );

    U8 buffer[4096];
    I64 received;

    received = WebSocketReceive(
        ws,
        buffer,
        sizeof(buffer)
    );

    if(received > 0)
    {
    Print("Received frame\n");

    WebSocketFrame frame;

    if(DecodeWebSocketFrame(
        buffer,
        received,
        &frame
    ))
    {
        Print("Frame decoded\n");

        Print("Payload:\n");
        Print(frame.payload);
        Print("\n");
    }
    else
    {
        Print("Frame decode failed\n");
    }
    }
    else
    {
        Print("No frame received\n");
    }



    WebSocketClose(ws);

    return 0;
}