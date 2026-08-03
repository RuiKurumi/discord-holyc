#include "../net/socket_linux.HC"
#include "../net/tls_openssl.HC"

#include "../include/tls.HH"
#include "../include/print.HH"

I32 Main(I32 argc, U8 **argv)
{
    TLSContext *tls;
    U8 buffer[4096];

    tls = TLSConnect("youtube.com", 443);

    if(!tls)
    {
        Print("TLS connection failed\n");
        return 1;
    }

    Print("Sending HTTPS request\n");

    U8 *request;

    request = 
    "GET / HTTP/1.1\r\n"
    "Host: youtube.com\r\n"
    "Connection: close\r\n"
    "\r\n";

    TLSSend(
        tls,
        request,
        StrLen(request)
    );

    I64 received;

    received = TLSReceive(
        tls,
        buffer,
        sizeof(buffer) - 1
    );

    if(received > 0)
    {
        buffer[received] = 0;
        Print(buffer);
    }

    TLSClose(tls);

    return 0;
}