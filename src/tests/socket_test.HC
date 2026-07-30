#include "../net/socket_linux.HC"
#include "../include/print.HH"

I32 Main(I32 argc, U8 **argv)
{
    Socket *sock;
    U8 buffer[4096];

    sock = SocketConnect("youtube.com", 80);

    if(!sock)
    {
        Print("Connection failed\n");
        return 1;
    }

    Print("Sending request\n");

    SocketSend(
        sock,
        "GET / HTTP/1.1\r\nHost: youtube.com\r\nConnection: close\r\n\r\n",
        59
    );


    I64 received;

    received = SocketReceive(
        sock,
        buffer,
        sizeof(buffer)-1
    );

    if(received > 0)
    {
        buffer[received] = 0;
        Print(buffer);
    }


    SocketClose(sock);

    return 0;
}