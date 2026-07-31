#include "../include/websocket.HH"
#include "../include/print.HH"
#include "../include/string.HH"


#define WS_OPCODE_TEXT 0x1
#define WS_OPCODE_BINARY 0x2
#define WS_OPCODE_CLOSE 0x8
#define WS_OPCODE_PING 0x9
#define WS_OPCODE_PONG 0xA

U8 *EncodeWebSocketFrame(
    U8 opcode,
    U8 *payload,
    I64 length,
    I64 *out_length
);

U8 *BuildHandshakeRequest(
    U8 *host,
    U8 *path
);

Bool VerifyHandshake(
    U8 *response);


WebSocket *WebSocketConnect(
    U8 *host,
    U8 *path
)
{
    U8 *request;
    U8 response[4096];
    I64 received;

    Print("Entered WebSocketConnect\n");

    WebSocket *ws;

    ws = MAlloc(sizeof(WebSocket));

    if(!ws)
        return NULL;

    ws->connected = FALSE;

    ws->tls = TLSConnect(
        host,
        443
    );

    if(!ws->tls)
    {
        Print("TLSConnect returned NULL\n");
        Free(ws);
        return NULL;
    }

    Print("TLSConnect returned valid context\n");

    /* Build HTTP Upgrade request */
    request = BuildHandshakeRequest(
        host,
        path
    );

    if(!request)
    {
        TLSClose(ws->tls);
        Free(ws);
        return NULL;
    }

    Print("Sending handshake\n");

    /* Send request */
    TLSSend(
        ws->tls,
        request,
        StrLen(request)
    );

    Print("Receiving response\n");

    /* Receive response */
    received = TLSReceive(
        ws->tls,
        response,
        sizeof(response) - 1
    );

    if(received > 0)
    {
        response[received] = 0;

        Print(response);
    }

    if(!VerifyHandshake(response))
    {
    Print("Handshake verification failed\n");

    Free(request);
    TLSClose(ws->tls);
    Free(ws);

    return NULL;
    }

    Free(request);


    Print("Returning WebSocket\n");

    ws->connected = TRUE;

    return ws;
}


I64 WebSocketSend(
    WebSocket *ws,
    U8 *data,
    I64 length
)
{
    U8 *frame;
    I64 frame_length;
    I64 result;


    if(!ws)
        return -1;

    if(!ws->connected)
        return -1;


    frame = EncodeWebSocketFrame(
        WS_OPCODE_TEXT,
        data,
        length,
        &frame_length
    );


    if(!frame)
        return -1;


    result = TLSSend(
        ws->tls,
        frame,
        frame_length
    );


    Free(frame);

    return result;
}


I64 WebSocketReceive(
    WebSocket *ws,
    U8 *buffer,
    I64 length
)
{
    if(!ws)
        return -1;

    if(!ws->connected)
        return -1;

    return TLSReceive(
        ws->tls,
        buffer,
        length
    );
}


U0 WebSocketClose(
    WebSocket *ws
)
{
    if(!ws)
        return;

    if(ws->tls)
        TLSClose(ws->tls);

    Free(ws);
}


/* ===========================
   Private helper functions
   =========================== */

extern "c" I32 snprintf(
    U8 *str,
    U64 size,
    U8 *fmt,
    ...
);

U8 *BuildHandshakeRequest(
    U8 *host,
    U8 *path
)
{
    U8 *request;

    request = MAlloc(1024);

    if(!request)
        return NULL;

    snprintf(
        request,
        1024,
        "GET %s HTTP/1.1\r\n"
        "Host: %s\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
        "\r\n",
        path,
        host
    );

    return request;
}


Bool VerifyHandshake(U8 *response)
{
    Print("Running VerifyHandshake\n");

    if(!response)
    {
        Print("Response is NULL\n");
        return FALSE;
    }

    if(StrContains(response, "101 Switching Protocols"))
    {
        Print("Found 101\n");
        return TRUE;
    }

    Print("Did not find 101\n");
    Print(response);
    Print("\n");

    
    return FALSE;
}

U8 *EncodeWebSocketFrame(
    U8 opcode,
    U8 *payload,
    I64 length,
    I64 *out_length
)
{
    U8 *frame;
    I64 total;


    /*
       Client frames always:
       FIN = 1
       MASK = 1
    */


    total = length + 6;


    frame = MAlloc(total);

    if(!frame)
        return NULL;


    frame[0] = 0x80 | opcode;
    frame[1] = 0x80 | length;

    Print("Frame created\n");


    /*
       Fixed mask for initial testing.
       Later replace with random bytes.
    */

    frame[2] = 0x12;
    frame[3] = 0x34;
    frame[4] = 0x56;
    frame[5] = 0x78;


    I64 i;

    for(i = 0; i < length; i++)
    {
        frame[6+i] =
            payload[i] ^
            frame[2+(i%4)];
    }


    *out_length = total;


    return frame;
}

Bool DecodeWebSocketFrame(
    U8 *buffer,
    I64 length,
    WebSocketFrame *frame
)
{
    if(length < 2)
        return FALSE;


    frame->opcode = buffer[0] & 0x0F;


    frame->payload_length = buffer[1] & 0x7F;


    I64 offset = 2;


    if(frame->payload_length == 126)
    {
        frame->payload_length =
            (buffer[2] << 8) |
            buffer[3];

        offset += 2;
    }
    else if(frame->payload_length == 127)
    {
        // handle later
        return FALSE;
    }


    frame->payload = buffer + offset;


    return TRUE;
}