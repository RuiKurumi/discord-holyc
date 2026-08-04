#include "../include/gateway.HH"
#include "../include/websocket.HH"
#include "../include/string.HH"



Bool GatewayRun(
    Gateway *gateway
)
{
    if(!gateway)
        return FALSE;

    while(TRUE)
    {
        if(!GatewayPoll(gateway))
        {
            Print("Gateway disconnected\n");
            return FALSE;
        }

        /* Heartbeat logic goes here */

        if(gateway->ready)
        {
            if(
                TimeNow() >=
                gateway->last_heartbeat_sent +
                (gateway->heartbeat_interval / 1000)
            )
            {
                if(!gateway->heartbeat_received)
                {
                    Print("Heartbeat timeout\n");
                    return FALSE;
                }

                GatewaySendHeartbeat(gateway);
            }
        }
    }
}

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

    gateway->last_heartbeat_sent = 0;
    gateway->last_heartbeat_ack = 0;
    gateway->heartbeat_received = TRUE;

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
        Print("DecodeWebSocketFrame failed\n");
        return NULL;
    }

    switch(frame.opcode)
    {
    case 1: /* Text */
        break;

    case 8: /* Close */
        if(frame.opcode == 8)
            {
                I64 code;

                Print("Received CLOSE frame\n");

                if(frame.payload_length >= 2)
                {
                    code =
                        (frame.payload[0] << 8) |
                        frame.payload[1];

                    if(code == 4004)
                    Print("Authentication failed\n");

                    if(code == 4002)
                        Print("Decode error\n");

                    if(code == 4008)
                        Print("Rate limited\n");

                    if(code == 4013)
                        Print("Invalid intents\n");

                    if(code == 4014)
                        Print("Disallowed intents\n");
                }

                return NULL;
            }

    case 9: /* Ping */
        Print("Received PING\n");
        /* TODO: Send Pong */
        return NULL;

    case 10: /* Pong */
        Print("Received PONG\n");
        return NULL;

    default:
        Print("Unknown WebSocket opcode\n");
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

Bool GatewayPoll(
    Gateway *gateway
)
{
    U8 *json;
    GatewayPacket *packet;

    if(!gateway)
        return FALSE;

    json = GatewayReceive(gateway);

    if(!json)
        return FALSE;

    packet = GatewayPacketParse(json);

    Free(json);

    if(!packet)
        return TRUE;

    GatewayHandlePacket(
        gateway,
        packet
    );

    GatewayPacketFree(packet);

    return TRUE;
}

U0 GatewayFree(
    Gateway *gateway
)
{
    if(!gateway)
        return;

    if(gateway->socket)
    {
        WebSocketClose(gateway->socket);
    }

    if(gateway->token)
    {
        Free(gateway->token);
    }

    if(gateway->session_id)
    {
        Free(gateway->session_id);
    }

    Free(gateway);
}