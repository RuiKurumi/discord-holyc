#include "../include/gateway_events.HH"
#include "../include/print.HH"


U0 GatewayHandlePacket(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    switch(packet->op)
    {
        case 0:
            GatewayHandleDispatch(
                gateway,
                packet
            );
            break;

        case 7:
            GatewayHandleReconnect(
                gateway,
                packet
            );
            break;

        case 9:
            GatewayHandleInvalidSession(
                gateway,
                packet
            );
            break;

        case 10:
            GatewayHandleHello(
                gateway,
                packet
            );
            break;

        case 11:
            GatewayHandleHeartbeatAck(
                gateway,
                packet
            );
            break;
    }
}
U0 GatewayHandleHello(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    Print("Gateway Hello\n");
}
U0 GatewayHandleDispatch(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    Print("Dispatch\n");
}
U0 GatewayHandleHeartbeatAck(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    Print("Heartbeat ACK\n");
}
U0 GatewayHandleReconnect(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    Print("Reconnect\n");
}
U0 GatewayHandleInvalidSession(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    Print("Invalid Session\n");
}
Bool GatewaySendHeartbeat(
    Gateway *gateway
)
{
    return FALSE;
}

Bool GatewaySendIdentify(
    Gateway *gateway,
    U8 *token
)
{
    return FALSE;
}

Bool GatewaySendResume(
    Gateway *gateway,
    U8 *session_id,
    U8 *token
)
{
    return FALSE;
}