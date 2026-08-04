#include "../include/tls.HH"

extern "c" U0 *TLS_client_method();

extern "c" U0 *SSL_CTX_new(U0 *method);
extern "c" U0 SSL_CTX_free(U0 *ctx);

extern "c" U0 *SSL_new(U0 *ctx);
extern "c" U0 SSL_free(U0 *ssl);

extern "c" I32 SSL_set_fd(U0 *ssl, I32 fd);
extern "c" I32 SSL_connect(U0 *ssl);

extern "c" I32 SSL_read(
    U0 *ssl,
    U0 *buf,
    I32 len
);

extern "c" I32 SSL_write(
    U0 *ssl,
    U0 *buf,
    I32 len
);

extern "c" I32 SSL_shutdown(U0 *ssl);


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
    Print("Creating SSL_CTX\n");
    tls->ssl_ctx = SSL_CTX_new(
        TLS_client_method()
    );

    if(!tls->ssl_ctx)
    {
        Print("SSL_CTX_new failed\n");
        SocketClose(tls->socket);
        Free(tls);
        return NULL;
    }

    tls->ssl = SSL_new(
        tls->ssl_ctx
    );

    if(!tls->ssl)
    {
        Print("SSL_new failed\n");
        SSL_CTX_free(tls->ssl_ctx);
        SocketClose(tls->socket);
        Free(tls);
        return NULL;
    }
    Print("Binding socket\n");
    if(
        SSL_set_fd(
            tls->ssl,
            tls->socket->fd
        ) != 1
    )
    {
        Print("SSL_set_fd failed\n");
        SSL_free(tls->ssl);
        SSL_CTX_free(tls->ssl_ctx);
        SocketClose(tls->socket);
        Free(tls);
        return NULL;
    }

    if(
        SSL_connect(
            tls->ssl
        ) != 1
    )
    {
        Print("SSL_connect failed\n");
        SSL_free(tls->ssl);
        SSL_CTX_free(tls->ssl_ctx);
        SocketClose(tls->socket);
        Free(tls);
        return NULL;
    }

    tls->established = TRUE;
    Print("TLS handshake succeeded\n");
    return tls;
}


I64 TLSSend(
    TLSContext *ctx,
    U8 *buffer,
    I64 length
)
{
    if(!ctx)
    return -1;

    if(!ctx->established)
    return -1;

    return SSL_write(
        ctx->ssl,
        buffer,
        length
    );
}


I64 TLSReceive(
    TLSContext *ctx,
    U8 *buffer,
    I64 length
)
{
    if(!ctx)
    return -1;

    if(!ctx->established)
    return -1;

    return SSL_read(
        ctx->ssl,
        buffer,
        length
    );
}


U0 TLSClose(
    TLSContext *ctx
)
{
    if(!ctx)
        return;

    if(ctx->ssl)
    {
        SSL_shutdown(ctx->ssl);
        SSL_free(ctx->ssl);
    }

    if(ctx->ssl_ctx)
        SSL_CTX_free(ctx->ssl_ctx);

    if(ctx->socket)
        SocketClose(ctx->socket);

    Free(ctx);
}