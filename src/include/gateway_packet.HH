#ifndef GATEWAY_PACKET_HH
#define GATEWAY_PACKET_HH

#include "../include/kson.HH"

class GatewayPacket
{
    I64 op;

    KSONValue *d;

    U8 *t;

    I64 s;
};


/* Parsing */

GatewayPacket *GatewayPacketParse(
    U8 *json
);

U8 *GatewayPacketStringify(
    GatewayPacket *packet
);

U0 GatewayPacketFree(
    GatewayPacket *packet
);


/* Builders */

GatewayPacket *GatewayPacketCreate(
    I64 op
);

#endif