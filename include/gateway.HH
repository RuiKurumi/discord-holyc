#ifndef GATEWAY_HH
#define GATEWAY_HH

#include "../include/websocket.HH"

class Gateway
{
    WebSocket *socket;

    U8 *token;
    U8 *session_id;
    I64 heartbeat_interval;
    I64 sequence;

    Bool ready;
    Bool reconnect_requested;
    
};

Gateway *GatewayConnect(
    U8 *token
);

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