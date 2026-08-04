#ifndef DISCORDHC_EVENTS_HH
#define DISCORDHC_EVENTS_HH

class DiscordClient;
class DiscordMessage;

class DiscordEventTable
{
    U0 (*ready)(DiscordClient *);

    U0 (*message_create)(
        DiscordClient *,
        DiscordMessage *
    );
};

#endif