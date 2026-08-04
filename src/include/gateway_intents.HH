#ifndef GATEWAY_INTENTS_HH
#define GATEWAY_INTENTS_HH

/* Discord Gateway Intents */

/* Guilds */
#define GATEWAY_INTENT_GUILDS                     (1 << 0)

/* Guild Members */
#define GATEWAY_INTENT_GUILD_MEMBERS              (1 << 1)

/* Guild Moderation */
#define GATEWAY_INTENT_GUILD_MODERATION           (1 << 2)

/* Guild Emojis and Stickers */
#define GATEWAY_INTENT_GUILD_EMOJIS               (1 << 3)

/* Guild Integrations */
#define GATEWAY_INTENT_GUILD_INTEGRATIONS         (1 << 4)

/* Guild Webhooks */
#define GATEWAY_INTENT_GUILD_WEBHOOKS             (1 << 5)

/* Guild Invites */
#define GATEWAY_INTENT_GUILD_INVITES              (1 << 6)

/* Guild Voice States */
#define GATEWAY_INTENT_GUILD_VOICE_STATES         (1 << 7)

/* Guild Presences (Privileged) */
#define GATEWAY_INTENT_GUILD_PRESENCES            (1 << 8)

/* Guild Messages */
#define GATEWAY_INTENT_GUILD_MESSAGES             (1 << 9)

/* Guild Message Reactions */
#define GATEWAY_INTENT_GUILD_MESSAGE_REACTIONS    (1 << 10)

/* Guild Message Typing */
#define GATEWAY_INTENT_GUILD_MESSAGE_TYPING       (1 << 11)

/* Direct Messages */
#define GATEWAY_INTENT_DIRECT_MESSAGES            (1 << 12)

/* Direct Message Reactions */
#define GATEWAY_INTENT_DIRECT_MESSAGE_REACTIONS   (1 << 13)

/* Direct Message Typing */
#define GATEWAY_INTENT_DIRECT_MESSAGE_TYPING      (1 << 14)

/* Message Content (Privileged) */
#define GATEWAY_INTENT_MESSAGE_CONTENT            (1 << 15)

/* Guild Scheduled Events */
#define GATEWAY_INTENT_GUILD_SCHEDULED_EVENTS     (1 << 16)

/* Auto Moderation */
#define GATEWAY_INTENT_AUTO_MODERATION_CONFIG     (1 << 20)
#define GATEWAY_INTENT_AUTO_MODERATION_EXECUTION  (1 << 21)

#endif