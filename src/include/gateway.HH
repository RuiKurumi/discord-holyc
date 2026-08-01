#ifndef GATEWAY_HH
#define GATEWAY_HH

#include "../include/websocket.HH"

class Gateway
{
    WebSocket *socket;

    I64 heartbeat_interval;
    I64 sequence;

    Bool ready;
};

Gateway *GatewayConnect(
    U8 *token
);

Gateway *GatewayConnect(
    U8 *token
)
{
    Gateway *gateway;

    gateway = MAlloc(sizeof(Gateway));

    if(!gateway)
        return NULL;

    gateway->socket = WebSocketConnect(
        "wss://gateway.discord.gg/?v=10&encoding=json"
    );

    if(!gateway->socket)
    {
        Free(gateway);
        return NULL;
    }

    gateway->heartbeat_interval = 0;
    gateway->sequence = -1;
    gateway->ready = FALSE;

    return gateway;
}

U8 *GatewayReceive(
    Gateway *gateway
);

Bool GatewaySend(
    Gateway *gateway,
    U8 *text
);

U0 GatewayDisconnect(
    Gateway *gateway
);

#endif