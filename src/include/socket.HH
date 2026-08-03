#include "socket_types.HH"

Socket *SocketConnect(U8 *host, I64 port);

I64 SocketSend(Socket *sock, U8 *buffer, I64 length);

I64 SocketReceive(Socket *sock, U8 *buffer, I64 length);

U0 SocketClose(Socket *sock);