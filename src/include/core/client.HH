#ifndef DISCORDHC_CLIENT_HH
#define DISCORDHC_CLIENT_HH

#include "../gateway.HH"
#include "../events.HH"

class DiscordClient
{
    /* Internal connection */
    Gateway *gateway;

    /* Bot token */

    /* Client state */
    Bool running;

    /* Gateway intents */
    I64 intents;

    /* Event callbacks */
    DiscordEventTable events;
};



#endif