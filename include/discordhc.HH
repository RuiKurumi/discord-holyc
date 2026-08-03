#ifndef DISCORDHC_HH
#define DISCORDHC_HH

#define DISCORDHC_VERSION "0.1.0"

#include "../../../holyc-lang/src/holyc-lib/tos.HH"

#include "socket_types.HH"
#include "socket.HH"

class DiscordClient
{
    Socket *socket;
    U8 *token;
    Bool connected;
};

public DiscordClient *DiscordCreate(U8 *token);

public U0 DiscordDestroy(DiscordClient *client);

public U0 DiscordInit();

public U0 DiscordShutdown();

#endif