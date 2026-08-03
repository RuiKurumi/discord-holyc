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
    Gateway gateway;

    GatewayPacket *packet;

    KSONValue *data;

    Print("READY TEST\n");

    gateway.sequence = -1;
    gateway.ready = FALSE;
    gateway.session_id = NULL;

    packet = GatewayPacketCreate(0);

    packet->s = 123;

    packet->t = StrCopy("READY");

    data = KSONCreateObject();

    KSONObjectAdd(
        data,
        "session_id",
        KSONCreateString("abcdef123")
    );

    packet->d = data;

    GatewayHandleDispatch(
        &gateway,
        packet
    );

    printf(
        "Sequence: %lld\n",
        gateway.sequence
    );

    printf(
        "Ready: %d\n",
        gateway.ready
    );

    printf(
        "Session: %s\n",
        gateway.session_id
    );

    if(
        gateway.sequence == 123 &&
        gateway.ready &&
        StrCompare(
            gateway.session_id,
            "abcdef123"
        ) == 0
    )
    {
        Print("PASS\n");
    }
    else
    {
        Print("FAIL\n");
    }

    GatewayPacketFree(packet);

    if(gateway.session_id)
        Free(gateway.session_id);

    Print("RETURNING\n");
    return 0;
}