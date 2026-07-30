#include "../include/tls.HH"


extern "c" U0 *TLS_method();

extern "c" U0 *SSL_CTX_new(U0 *method);

extern "c" U0 *SSL_new(U0 *ctx);

extern "c" U0 SSL_free(U0 *ssl);

extern "c" U0 SSL_CTX_free(U0 *ctx);


TLSContext *TLSConnect(U8 *host, I64 port)
{
    TLSContext *tls;

    tls = MAlloc(sizeof(TLSContext));

    if(!tls)
        return NULL;


    tls->socket = SocketConnect(host, port);

    if(!tls->socket)
    {
        Free(tls);
        return NULL;
    }


    tls->established = FALSE;

    return tls;
}