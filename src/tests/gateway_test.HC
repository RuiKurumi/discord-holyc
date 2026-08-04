#include "../include/gateway_packet.HH"
#include "../include/kson.HH"
#include "../include/print.HH"
#include "../include/string.HH"
#include "../include/gateway_events.HH"

#include "../runtime/string.HC"

#include "../json/kson.HC"

#include "../gateway/gateway_packet.HC"
#include "../gateway/gateway_events.HC"
#include "../include/gateway.HH"
#include "../gateway/gateway.HC"

#include "../net/socket_linux.HC"
#include "../net/tls_openssl.HC"
#include "../net/websocket.HC"


extern "c" I32 printf(U8 *, ...);

I32 Main()
{
    Gateway *gateway;
    U8 *json;
    GatewayPacket *packet;

gateway = GatewayConnect("Bot TEST_TOKEN");

if(!gateway)
{
    Print("GatewayConnect FAILED\n");
    return 1;
}

json = GatewayReceive(gateway);

if(!json)
{
    Print("GatewayReceive FAILED\n");
    return 1;
}

Print(json);
Print("Received:\n");
packet = GatewayPacketParse(json);

if(!packet)
{
    Print("Parse failed\n");
    return 1;
}

printf("Opcode: %lld\n", packet->op);

    return 0;
}