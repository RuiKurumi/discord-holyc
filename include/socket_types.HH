#ifndef SOCKET_TYPES_HH
#define SOCKET_TYPES_HH

class Socket
{
    I64 fd;
    Bool connected;
};


class AddrInfo
{
    I32 flags;
    I32 family;
    I32 socktype;
    I32 protocol;
    I64 addrlen;
    U0 *addr;
    AddrInfo *next;
};
#endif