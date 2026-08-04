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


U0 main()
{
    Gateway *gateway;

    gateway = GatewayConnect(
        "Bot "
    );

    if(!gateway)
    {
        Print("GatewayConnect failed\n");
        return;
    }

    Print("Gateway connected\n");

    GatewayRun(gateway);

    Print("GatewayRun exited\n");

    GatewayFree(gateway);
}