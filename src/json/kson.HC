#include "../include/kson.HH"
#include "../include/string.HH"
#include "../runtime/string.HC"

/* ===========================
   Private helper functions
   =========================== */

U8 *SkipWhitespace(
    U8 *text
);

KSONValue *ParseValue(
    U8 **text
);

KSONValue *ParseObject(
    U8 **text
);

KSONValue *ParseString(
    U8 **text
);

KSONValue *ParseNumber(
    U8 **text
);

/* ===========================
   Public API
   =========================== */

KSONValue *KSONParse(
    U8 *text
)
{
    if(!text)
    return NULL;

    text = SkipWhitespace(text);

    return ParseValue(&text);
}

KSONValue *KSONGet(
    KSONValue *object,
    U8 *key
)
{
    KSONValue *child;

    if(!object)
        return NULL;

    child = object->child;

    while(child)
    {
        if(StrCompare(child->key, key) == 0)
            return child;

            child = child->next;
    }

    return NULL;
}

U0 KSONFree(
    KSONValue *value
)
{
    if(!value)
        return;

    if(value->child)
        KSONFree(value->child);

    if(value->next)
        KSONFree(value->next);

    if(value->string_value)
        Free(value->string_value);

    if(value->key)
        Free(value->key);

    Free(value);
}

U8 *SkipWhitespace(
    U8 *text
)
{
    while(
        *text == ' '  ||
        *text == '\t' ||
        *text == '\r' ||
        *text == '\n'
    )
    {
        text++;
    }

    return text;
}

KSONValue *ParseValue(
    U8 **text
)
{
    *text = SkipWhitespace(*text);

    if(**text == '"')
        return ParseString(text);

    if(**text >= '0' && **text <= '9')
        return ParseNumber(text);

    if(**text == '{')
        return ParseObject(text);

    return NULL;
}

KSONValue *ParseObject(
    U8 **text
)
{
    return NULL;
}

KSONValue *ParseString(
    U8 **text
)
{
    KSONValue *value;
    U8 *start;
    I64 length;
    I64 i;

    if(**text != '"')
        return NULL;

    (*text)++;

    start = *text;

    while(**text && **text != '"')
    {
        *text = *text + 1;
    }

    length = *text - start;

    value = MAlloc(sizeof(KSONValue));

    if(!value)
        return NULL;

    value->type = KSON_STRING;
    value->number_value = 0;

    value->child = NULL;
    value->next = NULL;
    value->key = NULL;

    value->string_value = MAlloc(length + 1);

    if(!value->string_value)
    {
        Free(value);
        return NULL;
    }

    for(i = 0; i < length; i++)
        value->string_value[i] = start[i];

    value->string_value[length] = 0;

    if(**text == '"')
        *text = *text + 1;

    return value;
}

KSONValue *ParseNumber(
    U8 **text
)
{
    KSONValue *value;

    value = MAlloc(sizeof(KSONValue));

    if(!value)
        return NULL;

    value->type = KSON_NUMBER;
    value->number_value = 0;
    
    value->string_value = NULL;
    value->child = NULL;
    value->next = NULL;
    value->key = NULL;

    while(**text >= '0' && **text <= '9')
    {
        value->number_value =
            value->number_value * 10 +
            (**text - '0');

        (*text)++;
    }

    return value;
}