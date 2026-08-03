#include "../include/gateway_events.HH"
#include "../include/gateway_packet.HH"
#include "../include/kson.HH"
#include "../include/print.HH"


U0 GatewayHandlePacket(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    if(!gateway)
        return;

    if(!packet)
        return;

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

        default:
            Print("Unknown Gateway Opcode\n");
            break;
    }
}


Bool GatewayHandleHello(
    Gateway *gateway,
    GatewayPacket *packet
)
{
   KSONValue *interval;
   

    if(!gateway)
        return FALSE;

    if(!packet)
        return FALSE;

    if(!packet->d)
        return FALSE;

    interval = KSONGet(
        packet->d,
        "heartbeat_interval"
    );

    if(!interval)
        return FALSE;

    gateway->heartbeat_interval =
         interval->number_value;

    Print("Gateway HELLO\n");
    Print("Feet Pics recieved\n");
    return TRUE;
}


U0 GatewayHandleDispatch(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    if(!gateway)
        return;

    if(!packet)
        return;

    gateway->sequence = packet->s;

    if(!packet->t)
        return;

    Print("Gateway Dispatch: ");
    Print(packet->t);
    Print("\n");

    if(StrCompare(packet->t, "READY") == 0)
    {
        KSONValue *session;

        session = KSONGet(
            packet->d,
            "session_id"
        );

        if(session && session->string_value)
        {
            if(gateway->session_id)
            {
                Free(gateway->session_id);
            }

            gateway->session_id =
                StrCopy(session->string_value);
        }

        gateway->ready = TRUE;

        Print("Gateway READY\n");
    }
}


U0 GatewayHandleReconnect(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    if(!gateway)
        return;

    Print("Gateway Reconnected\n");

    gateway->ready = FALSE;
    gateway->ready = TRUE;
}


U0 GatewayHandleInvalidSession(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    if(!gateway)
        return;
    
    if(!packet)
        return;

    Print("Gateway INVALID SESSION\n");

    gateway->ready = FALSE;

    if(packet->d &&
        packet->d->type == KSON_BOOLEAN &&
        packet->d->number_value
    )
    {
        Print("Session can be resumed.\n");

        gateway->reconnect_requested = TRUE;
    }
    else
    {
        Print("Session cannot be resumed.\n");

        if(gateway->session_id)
        {
            Free(gateway->session_id);
            gateway->session_id = NULL;
        }

        gateway->sequence = -1;

        gateway->reconnect_requested = TRUE;
    }
}


U0 GatewayHandleHeartbeatAck(
    Gateway *gateway,
    GatewayPacket *packet
)
{
    if(!gateway)
        return;

    if(!packet)
        return;

    Print("Gateway HEARTBEAT ACK\n");
}

Bool GatewaySendIdentify(
    Gateway *gateway
)
{
    return FALSE;
}

Bool GatewaySendHeartbeat(
    Gateway *gateway
)
{
    GatewayPacket *packet;
    U8 *json;

    if(!gateway)
        return FALSE;

    packet = GatewayPacketCreate(1);

    if(!packet)
        return FALSE;

    if(gateway->sequence >= 0)
    {
        packet->d = KSONCreateNumber(
            gateway->sequence
        );
    }
    else 
    {
        packet->d = KSONCreateNull();
    }

    json = GatewayPacketStringify(
        packet
    );

    if(!json)
    {
        GatewayPacketFree(packet);
        return FALSE;
    }

    if(!GatewaySend(
        gateway,
        json
    ))
    {
        Free(json);
        GatewayPacketFree(packet);
        return FALSE;
    }

    Free(json);
    GatewayPacketFree(packet);

    return TRUE;
}

Bool GatewaySendResume(
    Gateway *gateway
)
{
    GatewayPacket *packet;

    KSONValue *data;

    U8 *json;

    if(!gateway)
        return FALSE;

    if(!gateway->token)
        return FALSE;

    if(!gateway->session_id)
        return FALSE;

    packet = GatewayPacketCreate(6);

    if(!packet)
        return FALSE;

    data = KSONCreateObject();

    if(!data)
    {
        GatewayPacketFree(packet);
        return FALSE;
    }

    KSONObjectAdd(
        data,
        "token",
        KSONCreateString(gateway->token)
    );

    KSONObjectAdd(
        data,
        "session_id",
        KSONCreateString(gateway->session_id)
    );

    KSONObjectAdd(
        data,
        "seq",
        KSONCreateNumber(gateway->sequence)
    );

    packet->d = data;
    json = GatewayPacketStringify(packet);

    if(!json)
    {
        GatewayPacketFree(packet);
        return FALSE;
    }

    if(!GatewaySend(gateway, json))
    {
        Free(json);
        GatewayPacketFree(packet);
        return FALSE;
    }

    Free(json);
    GatewayPacketFree(packet);

    return TRUE;
}