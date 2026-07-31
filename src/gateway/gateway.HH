#ifndef GATEWAY_HH
#define GATEWAY_HH

#include "../include/websocket.HH"

class Gateway
{
    Websocket *socket;

    I64 heartbeat_interval;

    I64 sequence;

    Bool ready;
};

Gateway *GatewayConnect(
    U8 *token
);

#endif