#include "../include/gateway.HH"
#include "../include/websocket.HH"
#include "../include/string.HH"

Gateway *GatewayConnect(
    U8 *token
)
{
    Gateway *gateway;

    gateway = MAlloc(sizeof(Gateway));

    if(!gateway)
        return NULL;

    gateway->socket = WebSocketConnect(
        "gateway.discord.gg",
        "/?v=10&encoding=json"
    );

    if(!gateway->socket)
    {
        Free(gateway);
        return NULL;
    }

    gateway->token = StrCopy(token);
    gateway->session_id = NULL;

    gateway->heartbeat_interval = 0;
    gateway->sequence = -1;
    gateway->ready = FALSE;
    gateway->reconnect_requested = FALSE;

    return gateway;
}


U8 *GatewayReceive(
    Gateway *gateway
)
{
    U8 buffer[8192];

    I64 received;

    WebSocketFrame frame;

    U8 *json;

    if(!gateway)
        return NULL;

    if(!gateway->socket)
        return NULL;

    received = WebSocketReceive(
        gateway->socket,
        buffer,
        sizeof(buffer) - 1
    );

    if(received <= 0)
        return NULL;

    if(
        !DecodeWebSocketFrame(
            buffer,
            received,
            &frame
        )
    )
    {
        return NULL;
    }

    json = MAlloc(
        frame.payload_length + 1
    );

    if(!json)
        return NULL;

    MemCopy(
        json,
        frame.payload,
        frame.payload_length
    );

    json[frame.payload_length] = 0;

    return json;
}


Bool GatewaySend(
    Gateway *gateway,
    U8 *text
)
{
    if(!gateway)
        return FALSE;

    if(!gateway->socket)
        return FALSE;

    return
        WebSocketSend(
            gateway->socket,
            text,
            StrLen(text)
        ) >= 0;
}


U0 GatewayDisconnect(
    Gateway *gateway
)
{
    if(!gateway)
        return;

    if(gateway->socket)
    {
        WebSocketClose(
            gateway->socket
        );
    }

    if(gateway->session_id)
        Free(gateway->session_id);

    if(gateway->token)
        Free(gateway->token);

    Free(gateway);
}