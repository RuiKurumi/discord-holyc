#ifndef GATEWAY_EVENTS_HH
#define GATEWAY_EVENTS_HH

#include "../include/gateway.HH"
#include "../include/gateway_packet.HH"

/* Packet dispatcher */

U0 GatewayHandlePacket(
    Gateway *gateway,
    GatewayPacket *packet
);


/* Incoming events */
Bool GatewayHandleHello(
    Gateway *gateway,
    GatewayPacket *packet
);

U0 GatewayHandleDispatch(
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

U0 GatewayHandleHeartbeatAck(
    Gateway *gateway,
    GatewayPacket *packet
);


/* Outgoing events */

Bool GatewaySendIdentify(
    Gateway *gateway
);

Bool GatewaySendHeartbeat(
    Gateway *gateway
);

Bool GatewaySendResume(
    Gateway *gateway
);

#endif