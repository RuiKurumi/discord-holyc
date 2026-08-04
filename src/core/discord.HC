#include <discordhc.HH>

I32 Main(I32 argc, U8 **argv)
{
    DiscordClient *client;

    if(!DiscordInit())
        return 1;

    client = DiscordCreate(
        "Bot YOUR_TOKEN"
    );

    if(!client)
        return 1;

    DiscordRun(client);

    DiscordFree(client);

    DiscordShutdown();

    return 0;
}