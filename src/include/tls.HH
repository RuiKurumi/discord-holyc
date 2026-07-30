#ifndef TLS_HH
#define TLS_HH

#include "socket.HH"

class TLSContext
{
    Socket *socket;

    U0 *ssl_ctx;
    U0 *ssl;

    Bool established;
};


TLSContext *TLSConnect(
    U8 *host,
    I64 port
);


I64 TLSSend(
    TLSContext *ctx,
    U8 *buffer,
    I64 length
);


I64 TLSReceive(
    TLSContext *ctx,
    U8 *buffer,
    I64 length
);


U0 TLSClose(
    TLSContext *ctx
);

#endif