#ifndef GATEWAY_EVENTS_HH
#define GATEWAY_EVENTS_HH

#include "../include/gateway.HH"
#include "../include/gateway_packet.HH"


/* Incoming */

U0 GatewayHandlePacket(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleHello(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleDispatch(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleHeartbeatAck(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleReconnect(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleInvalidSession(
    Gateway *gateway,
    GatewayPacket *packet
);


/* Outgoing */

Bool GatewaySendHeartbeat(
    Gateway *gateway
);

Bool GatewaySendIdentify(
    Gateway *gateway,
    U8 *token
);

Bool GatewaySendResume(
    Gateway *gateway,
    U8 *session_id,
    U8 *token
);

#endif