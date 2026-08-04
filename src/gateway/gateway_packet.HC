#include "../include/gateway_packet.HH"
#include "../include/string.HH"
#include "../include/kson.HH"

static KSONValue *DetachObjectField(
    KSONValue *object,
    U8 *key
);

GatewayPacket *GatewayPacketCreate(
    I64 op
)
{
    GatewayPacket *packet;

    packet = MAlloc(sizeof(GatewayPacket));

    if(!packet)
        return NULL;

    packet->op = op;
    packet->d = NULL;
    packet->t = NULL;
    packet->s = -1;

    return packet;
}


GatewayPacket *GatewayPacketParse(
    U8 *json
)
{
    KSONValue *root;

    KSONValue *op;
    KSONValue *s;
    KSONValue *t;

    GatewayPacket *packet;

    root = KSONParse(json);
    Print("KSONParse returned\n");

    if(!root)
        return NULL;

    Print("Getting op\n");
    op = KSONGet(root, "op");

    if(!op)
    {
        Print("op is NULL\n");
        KSONFree(root);
        return NULL;
    }
    else
    {
        Print("op exists\n");

        if(op->type == KSON_NUMBER)
        {
            Print("op is number\n");
        }
        else
        {
            Print("op NOT number\n");
        }

        Print("About to read number_value\n");
         
    }
    Print("Creating packet\n");
    packet = GatewayPacketCreate(
        op->number_value
    );

    if(!packet)
    {
        KSONFree(root);
        return NULL;
    }
    Print("Detaching d\n");
    packet->d = DetachObjectField(
        root,
        "d"
    );
    Print("Getting s\n");
    s = KSONGet(root, "s");

    if(s)
    {
        packet->s = s->number_value;
        Print("Detaching t\n");
        t = DetachObjectField(
        root,
        "t"
        );
    }
    if(t)
    {
        if(
            t->type == KSON_STRING &&
            t->string_value
        )
        {
            packet->t = StrCopy(
                t->string_value
            );
        }

        KSONFree(t);
    }
    
    Print("Freeing root\n");
    KSONFree(root);

    Print("Returning packet\n");
    return packet;
}

static KSONValue *DetachObjectField(
    KSONValue *object,
    U8 *key
)
{
    KSONValue *current;
    KSONValue *previous;


    if(!object)
        return NULL;

    if(object->type != KSON_OBJECT)
        return NULL;

    current = object->child;
    previous = NULL;

    while(current)
    {
        if(current->key && StrCompare(current->key, key) == 0)
            {
                if(previous)
                    {
                        previous->next = current->next;
                    }
                    else
                    {
                        object->child = current->next;
                    }

                    current->next = NULL;
                if(current->key)
                    {
                        Free(current->key);
                        current->key = NULL;
                    }
                return current;
            }
        previous = current;
        current = current->next;
    }
    return NULL;
}
U0 GatewayPacketFree(
    GatewayPacket *packet
)
{
    if(!packet)
        return;

    if(packet->d)
        KSONFree(packet->d);

    if(packet->t)
        Free(packet->t);

    Free(packet);
}
U8 *GatewayPacketStringify(
    GatewayPacket *packet
)
{
    Print("Stringifying root\n");
    KSONValue *root;
    U8 *json;

    if(!packet)
        return NULL;

    root = KSONCreateObject();

    if(!root)
        return NULL;

    KSONObjectAdd(
        root,
        "op",
        KSONCreateNumber(packet->op)
    );

    if(packet->d)
    {
        Print("add d\n");
        KSONObjectAdd(
            root,
            "d",
            packet->d
        );

        /* Transfer ownership to the KSON tree */
        packet->d = NULL;
    }
    else
    {
        KSONObjectAdd(
            root,
            "d",
            KSONCreateNull()
        );
    }

    if(packet->s >= 0)
    {
        Print("add s\n");
        KSONObjectAdd(
            root,
            "s",
            KSONCreateNumber(packet->s)
        );
    }

    if(packet->t)
    {
        Print("add t\n");
        KSONObjectAdd(
            root,
            "t",
            KSONCreateString(packet->t)
        );
    }

    Print("Stringifying\n");
    json = KSONStringify(root);

    Print("root free\n");
    KSONFree(root);

    return json;
}