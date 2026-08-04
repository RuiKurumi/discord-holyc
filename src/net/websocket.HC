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
    U8 *response
);


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
    ws->tls = NULL;
    ws->host = NULL;
    ws->path = NULL;

    ws->host = StrCopy(host);
    ws->path = StrCopy(path);

    if(!ws->host || !ws->path)
    {
        if(ws->host)
            Free(ws->host);

        if(ws->path)
            Free(ws->path);

        Free(ws);

        return NULL;
    }

    ws->tls = TLSConnect(
        host,
        443
    );

    if(!ws->tls)
    {
        Print("TLSConnect returned NULL\n");

        Free(ws->host);
        Free(ws->path);
        Free(ws);

        return NULL;
    }

    Print("TLSConnect returned valid context\n");

    request = BuildHandshakeRequest(
        host,
        path
    );

    if(!request)
    {
        TLSClose(ws->tls);

        Free(ws->host);
        Free(ws->path);
        Free(ws);

        return NULL;
    }

    Print("Sending handshake\n");

    TLSSend(
        ws->tls,
        request,
        StrLen(request)
    );

    Print("Receiving response\n");

    received = TLSReceive(
        ws->tls,
        response,
        sizeof(response) - 1
    );

    if(received <= 0)
    {
        Free(request);

        TLSClose(ws->tls);

        Free(ws->host);
        Free(ws->path);
        Free(ws);

        return NULL;
    }

    response[received] = 0;

    Print(response);

    if(!VerifyHandshake(response))
    {
        Print("Handshake verification failed\n");

        Free(request);

        TLSClose(ws->tls);

        Free(ws->host);
        Free(ws->path);

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
    I64 bufferSize
)
{
    I64 received;
    I64 payloadLength;
    I64 offset;
    I64 more;

    if(!ws)
        return -1;

    if(!ws->connected)
        return -1;

    received = TLSReceive(
        ws->tls,
        buffer,
        bufferSize
    );

    if(received <= 0)
        return received;

    if(received < 2)
        return -1;

    payloadLength = buffer[1] & 0x7F;
    offset = 2;

    if(payloadLength == 126)
    {
        while(received < 4)
        {
            more = TLSReceive(
                ws->tls,
                buffer + received,
                bufferSize - received
            );

            if(more <= 0)
                return -1;

            received += more;
        }

        payloadLength =
            (buffer[2] << 8) |
            buffer[3];

        offset = 4;
    }
    else if(payloadLength == 127)
    {
        /* TODO */
        return -1;
    }

    while(received < offset + payloadLength)
    {
        more = TLSReceive(
            ws->tls,
            buffer + received,
            bufferSize - received
        );

        if(more <= 0)
            return -1;

        received += more;
    }

    return received;
}


U0 WebSocketClose(
    WebSocket *ws
)
{
    if(!ws)
        return;

    ws->connected = FALSE;

    if(ws->tls)
        TLSClose(ws->tls);

    if(ws->host)
        Free(ws->host);

    if(ws->path)
        Free(ws->path);

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
    I64 maskOffset;
    I64 payloadOffset;

 
    if(length <= 125)
    {
        total = length + 6;

        frame = MAlloc(total);
        if(!frame)
            return NULL;

        frame[0] = 0x80 | opcode;
        frame[1] = 0x80 | length;

        maskOffset = 2;
        payloadOffset = 6;
    }
    else if(length <= 65535)
    {
        total = length + 8;

        frame = MAlloc(total);
        if(!frame)
            return NULL;

        frame[0] = 0x80 | opcode;
        frame[1] = 0x80 | 126;

        frame[2] = (length >> 8) & 0xFF;
        frame[3] = length & 0xFF;

        maskOffset = 4;
        payloadOffset = 8;
    }
    else
    {
        Print("Payload too large\n");
        return NULL;
    }


    I64 i;

    frame[maskOffset + 0] = 0x12;
    frame[maskOffset + 1] = 0x34;
    frame[maskOffset + 2] = 0x56;
    frame[maskOffset + 3] = 0x78;
    for(i = 0; i < length; i++)
    {
        frame[payloadOffset + i] =
            payload[i] ^
            frame[maskOffset + (i % 4)];
    }


    *out_length = total;

    if(!frame)
        return NULL;

    return frame;
}

Bool DecodeWebSocketFrame(
    U8 *buffer,
    I64 length,
    WebSocketFrame *frame
)
{
    I64 offset;

    if(length < 2)
    {
         Print("FAIL: length < 2\n");
        return FALSE;
    }

    frame->opcode = buffer[0] & 0x0F;

    frame->payload_length = buffer[1] & 0x7F;

    offset = 2;

    if(frame->payload_length == 126)
    {
        if(length < 4)
        {
            Print("FAIL: truncated 126 header\n");
            return FALSE;
        }
        frame->payload_length =
            (buffer[2] << 8) |
            buffer[3];

        offset += 2;
    }
    else if(frame->payload_length == 127)
    {
        Print("FAIL: got 127-length frame\n");
        return FALSE;
    }

    if(offset + frame->payload_length > length)
    {
        Print("FAIL: incomplete frame\n");
        return FALSE;
    }
    frame->payload = buffer + offset;

    return TRUE;
}