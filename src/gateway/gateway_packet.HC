#include "../include/gateway_packet.HH"
#include "../include/string.HH"


GatewayPacket *GatewayPacketCreate(
    I64 op
)
{
    GatewayPacket *packet;

    packet = MAlloc(sizeof(GatewayPacket));

    if(!packet)
        return NULL;

    packet->op = op;
    packet->d = NULL;
    packet->t = NULL;
    packet->s = -1;

    return packet;
}