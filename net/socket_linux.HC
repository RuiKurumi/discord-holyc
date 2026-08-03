#include "../include/socket.HH"
#include "../include/print.HH"

extern "c" I32 socket(I32 domain, I32 type, I32 protocol);


extern "c" I32 getaddrinfo(
    U8 *node,
    U8 *service,
    U0 *hints,
    U0 *res
);

extern "c" U0 freeaddrinfo(U0 *res);

extern "c" I32 inet_addr(U8 *cp);

extern "c" I32 connect(
    I32 sockfd,
    U0 *addr,
    I32 addrlen
);

extern "c" I64 send(
    I32 sockfd,
    U0 *buf,
    U64 len,
    I32 flags
);

extern "c" I64 recv(
I32 sockfd,
U0 *buf,
U64 len,
I32 flags

);



extern "c" U16 htons(U16 hostshort);

extern "c" I32 close(I32 fd);

Socket *SocketConnect(U8 *host, I64 port)
{
    Socket *sock;
    AddrInfo *result;
    AddrInfo *current;

    U8 service[16];

    StrPrint(service, "%d", port);


    Print("Resolving host\n");


    if(getaddrinfo(
        host,
        service,
        NULL,
        &result
    ) != 0)
    {
        Print("DNS failed\n");
        return NULL;
    }


    current = result;


    while(current)
    {
        Print("Trying address\n");


        sock = MAlloc(sizeof(Socket));

        if(!sock)
        {
            freeaddrinfo(result);
            return NULL;
        }


        sock->fd = socket(
            current->family,
            current->socktype,
            current->protocol
        );


        if(sock->fd >= 0)
        {
            if(connect(
                sock->fd,
                current->addr,
                current->addrlen
            ) == 0)
            {
                sock->connected = TRUE;

                freeaddrinfo(result);

                Print("Connected\n");

                return sock;
            }

            close(sock->fd);
        }


        Free(sock);

        current = current->next;
    }


    freeaddrinfo(result);

    Print("Connection failed\n");

    return NULL;
}

I64 SocketSend(Socket *sock, U8 *buffer, I64 length)
{
    if(!sock || sock->fd < 0)
        return -1;

    return send(
        sock->fd,
        buffer,
        length,
        0
    );
}


I64 SocketReceive(Socket *sock, U8 *buffer, I64 length)
{
    if(!sock || sock->fd < 0)
        return -1;

    return recv(
        sock->fd,
        buffer,
        length,
        0
    );
}


U0 SocketClose(Socket *sock)
{
    if(!sock)
        return;

    if(sock->fd >= 0)
        close(sock->fd);

    Free(sock);
}
