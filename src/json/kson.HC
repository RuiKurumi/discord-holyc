#include "../include/kson.HH"
#include "../include/string.HH"
#include "../runtime/string.HC"
#include "../include/print.HH"


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

KSONValue *ParseNull(
    U8 **text
);

KSONValue *ParseBoolean(
    U8 **text
);

KSONValue *ParseArray(
    U8 **text
);

U8 *KSONStringify(
    KSONValue *value
);

U8 *KSONStringifyValue(
    KSONValue *value
);
U8 *KSONStringifyObject(
    KSONValue *value
);
U8 *KSONConcat(
    U8 *a,
    U8 *b
);
U8 *KSONStringifyArray(
    KSONValue *value
);

/* ===========================
   Public API
   =========================== */

KSONValue *KSONParse(
    U8 *text
)
{
    Print("KSONParse\n");

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

    if(object->type != KSON_OBJECT)
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
    Print("Freeing value\n");

    if(!value)
        return;


    if(value->child)
    {
        Print("Freeing child\n");
        KSONFree(value->child);
    }


    if(value->next)
    {
        Print("Freeing next\n");
        KSONFree(value->next);
    }


    if(value->string_value)
    {
        Print("Freeing string\n");
        Free(value->string_value);
    }


    if(value->key)
    {
        Print("Freeing key\n");
        Free(value->key);
    }


    Print("Freeing self\n");

    Free(value);
}U8 *SkipWhitespace(
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
    Print("ParseValue\n");

    *text = SkipWhitespace(*text);


    if(**text == '"')
        return ParseString(text);


    if(**text == '-' ||
       (**text >= '0' && **text <= '9'))
    {
        return ParseNumber(text);
    }


    if(**text == '{')
        return ParseObject(text);


    if(**text == 'n')
        return ParseNull(text);


    if(**text == 't' ||
       **text == 'f')
    {
        return ParseBoolean(text);
    }


    if(**text == '[')
        return ParseArray(text);


    return NULL;
}


KSONValue *ParseObject(
    U8 **text
)
{
    KSONValue *object;
    KSONValue *last;
    KSONValue *key;
    KSONValue *value;


    if(**text != '{')
        return NULL;


    *text = *text + 1;


    object = MAlloc(sizeof(KSONValue));

    if(!object)
        return NULL;


    object->type = KSON_OBJECT;

    object->child = NULL;
    object->next = NULL;

    object->key = NULL;
    object->string_value = NULL;

    object->number_value = 0;


    last = NULL;


    *text = SkipWhitespace(*text);


    if(**text == '}')
    {
        *text = *text + 1;
        return object;
    }


    while(TRUE)
    {
        *text = SkipWhitespace(*text);


        key = ParseString(text);

        if(!key)
        {
            KSONFree(object);
            return NULL;
        }


        *text = SkipWhitespace(*text);


        if(**text != ':')
        {
            KSONFree(key);
            KSONFree(object);

            return NULL;
        }


        (*text)++;


        *text = SkipWhitespace(*text);


        value = ParseValue(text);

        if(!value)
        {
            KSONFree(key);
            KSONFree(object);

            return NULL;
        }


        value->key = key->string_value;

        key->string_value = NULL;

        KSONFree(key);


        value->next = NULL;


        if(!object->child)
        {
            object->child = value;
        }
        else
        {
            last->next = value;
        }


        last = value;


        *text = SkipWhitespace(*text);


        if(**text == '}')
        {
            (*text)++;
            return object;
        }


        if(**text != ',')
        {
            KSONFree(object);
            return NULL;
        }


        (*text)++;
    }


    KSONFree(object);

    return NULL;
}

KSONValue *ParseString(
    U8 **text
)
{
    Print("ParseStr\n");

    KSONValue *value;

    U8 *start;

    I64 length;
    I64 i;


    if(**text != '"')
        return NULL;


    (*text)++;


    start = *text;


    while(
        **text &&
        **text != '"'
    )
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
    {
        value->string_value[i] = start[i];
    }


    value->string_value[length] = 0;


    if(**text == '"')
    {
        (*text)++;
    }


    return value;
}



KSONValue *ParseNumber(
    U8 **text
)
{
    Print("ParseNum\n");

    KSONValue *value;

    Bool negative;


    value = MAlloc(sizeof(KSONValue));


    if(!value)
        return NULL;


    negative = FALSE;


    if(**text == '-')
    {
        negative = TRUE;

        *text = *text + 1;
    }


    value->type = KSON_NUMBER;

    value->number_value = 0;


    value->string_value = NULL;

    value->child = NULL;
    value->next = NULL;

    value->key = NULL;


    while(
        **text >= '0' &&
        **text <= '9'
    )
    {
        value->number_value =
            value->number_value * 10 +
            (**text - '0');


        (*text)++;
    }


    if(negative)
    {
        value->number_value =
            -value->number_value;
    }


    return value;
}

KSONValue *ParseNull(
    U8 **text
)
{
    KSONValue *value;


    if(
        (*text)[0] != 'n' ||
        (*text)[1] != 'u' ||
        (*text)[2] != 'l' ||
        (*text)[3] != 'l'
    )
    {
        return NULL;
    }


    *text = *text + 4;


    value = MAlloc(sizeof(KSONValue));

    if(!value)
        return NULL;


    value->type = KSON_NULL;

    value->string_value = NULL;

    value->number_value = 0;

    value->child = NULL;
    value->next = NULL;

    value->key = NULL;


    return value;
}



KSONValue *ParseBoolean(
    U8 **text
)
{
    KSONValue *value;

    Bool result;


    result = FALSE;


    if(
        (*text)[0] == 't' &&
        (*text)[1] == 'r' &&
        (*text)[2] == 'u' &&
        (*text)[3] == 'e'
    )
    {
        result = TRUE;

        *text = *text + 4;
    }
    else
    {
        if(
            (*text)[0] == 'f' &&
            (*text)[1] == 'a' &&
            (*text)[2] == 'l' &&
            (*text)[3] == 's' &&
            (*text)[4] == 'e'
        )
        {
            result = FALSE;

            *text = *text + 5;
        }
        else
        {
            return NULL;
        }
    }


    value = MAlloc(sizeof(KSONValue));

    if(!value)
        return NULL;


    value->type = KSON_BOOLEAN;

    value->number_value = result;


    value->string_value = NULL;

    value->child = NULL;
    value->next = NULL;

    value->key = NULL;


    return value;
}



KSONValue *ParseArray(
    U8 **text
)
{
    KSONValue *array;
    KSONValue *last;
    KSONValue *value;


    if(**text != '[')
        return NULL;


    *text = *text + 1;


    array = MAlloc(sizeof(KSONValue));

    if(!array)
        return NULL;


    array->type = KSON_ARRAY;


    array->child = NULL;
    array->next = NULL;


    array->key = NULL;

    array->string_value = NULL;

    array->number_value = 0;


    last = NULL;


    *text = SkipWhitespace(*text);


    if(**text == ']')
    {
        *text = *text + 1;

        return array;
    }


    while(TRUE)
    {
        *text = SkipWhitespace(*text);


        value = ParseValue(text);


        if(!value)
        {
            KSONFree(array);

            return NULL;
        }


        if(!array->child)
        {
            array->child = value;
        }
        else
        {
            last->next = value;
        }


        last = value;


        *text = SkipWhitespace(*text);


        if(**text == ']')
        {
            *text = *text + 1;

            return array;
        }


        if(**text != ',')
        {
            KSONFree(array);

            return NULL;
        }


        *text = *text + 1;
    }


    KSONFree(array);

    return NULL;
}
U8 *KSONStringify(
    KSONValue *value
)
{
    if(!value)
        return NULL;


    if(value->type == KSON_NULL)
    {
        return "null";
    }

    if(value->type == KSON_STRING)
    {
        I64 length;
        I64 i;
        U8 *output;


        length = 0;

        while(value->string_value[length])
        {
            length++;
        }


        output = MAlloc(length + 3);

        if(!output)
            return NULL;


        output[0] = '"';


        for(i = 0; i < length; i++)
        {
            output[i + 1] = value->string_value[i];
        }


        output[length + 1] = '"';

        output[length + 2] = 0;


        return output;
    }

    if(value->type == KSON_OBJECT)
    {
        return KSONStringifyObject(value);
    }

    if(value->type == KSON_ARRAY)
    {
        return KSONStringifyArray(value);
    }

    if(value->type == KSON_BOOLEAN)
    {
        if(value->number_value)
            return "true";

        return "false";
    }

    if(value->type == KSON_NUMBER)
    {
        U8 buffer[64];

        snprintf(
            buffer,
            sizeof(buffer),
            "%lld",
            value->number_value
        );

        return StrCopy(buffer);
    }


    return NULL;
}
U8 *KSONStringifyObject(
    KSONValue *value
)
{
    KSONValue *child;

    U8 *output;

    I64 length;
    I64 i;


    if(!value)
        return NULL;


    if(value->type != KSON_OBJECT)
        return NULL;


    output = MAlloc(4096);

    if(!output)
        return NULL;


    length = 0;


    output[length++] = '{';


    child = value->child;


    while(child)
    {
        U8 *key;
        U8 *val;


        key = KSONStringify(
            KSONParse(
                "\"\""
            )
        );


        /*
            Temporary:
            replace this once we add a direct string helper.
        */


        val = KSONStringify(child);


        if(child->key)
        {
            output[length++] = '"';


            i = 0;

            while(child->key[i])
            {
                output[length++] = child->key[i];

                i++;
            }


            output[length++] = '"';

            output[length++] = ':';


            i = 0;

            while(val[i])
            {
                output[length++] = val[i];

                i++;
            }
        }


        child = child->next;


        if(child)
        {
            output[length++] = ',';
        }
    }


    output[length++] = '}';

    output[length] = 0;


    return output;
}
U8 *KSONStringifyArray(
    KSONValue *value
)
{
    KSONValue *child;

    U8 *output;

    I64 length;
    I64 i;


    if(!value)
        return NULL;


    if(value->type != KSON_ARRAY)
        return NULL;


    output = MAlloc(4096);

    if(!output)
        return NULL;


    length = 0;


    output[length++] = '[';


    child = value->child;


    while(child)
    {
        U8 *item;


        item = KSONStringify(child);


        if(!item)
        {
            Free(output);
            return NULL;
        }


        i = 0;

        while(item[i])
        {
            output[length++] = item[i];

            i++;
        }


        Free(item);


        child = child->next;


        if(child)
        {
            output[length++] = ',';
        }
    }


    output[length++] = ']';

    output[length] = 0;


    return output;
}