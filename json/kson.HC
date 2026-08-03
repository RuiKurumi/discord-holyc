#include "../include/kson.HH"
#include "../include/string.HH"
#include "../include/print.HH"


/* ===========================
   Private helper functions
   =========================== */

//parsing
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


//creating
KSONValue *CreateValue(
    I64 type
);

KSONValue *KSONCreateObject()
{
    return CreateValue(KSON_OBJECT);
}
KSONValue *KSONCreateArray()
{
    return CreateValue(KSON_ARRAY);
}
KSONValue *KSONCreateString(
    U8 *text
);
KSONValue *KSONCreateNumber();
KSONValue *KSONCreateBoolean(
    Bool value
);
KSONValue *KSONCreateNull()
{
    return CreateValue(KSON_NULL);
}
U0 KSONObjectAdd(
    KSONValue *object,
    U8 *key,
    KSONValue *value
);
U0 KSONArrayAdd(
    KSONValue *array,
    KSONValue *value
);



/* ===========================
   Public API
   =========================== */

U8 *SkipWhitespace(
    U8 *text
);


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


    object = KSONCreateObject();

    if(!object)
        return NULL;


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


    value = CreateValue(KSON_STRING);

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


    value = CreateValue(KSON_NUMBER);


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

    return KSONCreateNull();
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


    value = KSONCreateBoolean(result);

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


    array = KSONCreateArray();

    if(!array)
        return NULL;


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
        U8 *output;
        output = MAlloc(5);

        if(!output)
            return NULL;

        output[0] = 'n';
        output[1] = 'u';
        output[2] = 'l';
        output[3] = 'l';
        output[4] = 0;



        return output;
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
        U8 *output;

        

        if(value->number_value)
        {
            output = MAlloc(5);

            output[0] = 't';
            output[1] = 'r';
            output[2] = 'u';
            output[3] = 'e';
            output[4] = 0;

            return output;
        }

    output = MAlloc(6);

    output[0] = 'f';
    output[1] = 'a';
    output[2] = 'l';
    output[3] = 's';
    output[4] = 'e';
    output[5] = 0;

    return output;
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
    KSONBuffer *buffer;
    U8 *val;

    if(!value)
        return NULL;

    if(value->type != KSON_OBJECT)
        return NULL;

    buffer = KSONBufferCreate();

    if(!buffer)
        return NULL;

    KSONBufferAppendChar(
        buffer,
        '{'
    );

    child = value->child;

    while(child)
    {
        if(child->key)
        {
            KSONBufferAppendChar(
                buffer,
                '"'
            );

            KSONBufferAppend(
                buffer,
                child->key
            );

            KSONBufferAppendChar(
                buffer,
                '"'
            );

            KSONBufferAppendChar(
                buffer,
                ':'
            );

            val = KSONStringify(child);

            if(!val)
            {
                Free(buffer->data);
                Free(buffer);
                return NULL;
            }

            KSONBufferAppend(
                buffer,
                val
            );

            Free(val);
        }

        child = child->next;

        if(child)
        {
            KSONBufferAppendChar(
                buffer,
                ','
            );
        }
    }

    KSONBufferAppendChar(
        buffer,
        '}'
    );

    return KSONBufferFinish(
        buffer
    );
}
U8 *KSONStringifyArray(
    KSONValue *value
)
{
    KSONValue *child;
    KSONBuffer *buffer;
    U8 *item;

    if(!value)
        return NULL;

    if(value->type != KSON_ARRAY)
        return NULL;

    buffer = KSONBufferCreate();

    if(!buffer)
        return NULL;

    KSONBufferAppendChar(
        buffer,
        '['
    );

    child = value->child;

    while(child)
    {
        item = KSONStringify(child);

        if(!item)
        {
            Free(buffer->data);
            Free(buffer);
            return NULL;
        }

        KSONBufferAppend(
            buffer,
            item
        );

        Free(item);

        child = child->next;

        if(child)
        {
            KSONBufferAppendChar(
                buffer,
                ','
            );
        }
    }

    KSONBufferAppendChar(
        buffer,
        ']'
    );

    return KSONBufferFinish(
        buffer
    );
}
KSONValue *CreateValue(
    I64 type
)
{
    KSONValue *value;

    value = MAlloc(sizeof(KSONValue));

    if(!value)
        return NULL;

    value->type = type;

    value->string_value = NULL;
    value->number_value = 0;

    value->child = NULL;
    value->next = NULL;

    value->key = NULL;

    return value;
}
U0 KSONBufferAppend(
    KSONBuffer *buffer,
    U8 *text
)
{
    while(*text)
    {
        KSONBufferAppendChar(
            buffer,
            *text
        );

        text++;
    }
}
U8 *KSONBufferFinish(
    KSONBuffer *buffer
)
{
    U8 *data;

    data = buffer->data;

    Free(buffer);

    return data;
}
KSONValue *KSONCreateString(
    U8 *text
)
{
    KSONValue *value;
    I64 length;
    I64 i;

    if(!text)
    {
        return NULL;
    }

    value = CreateValue(KSON_STRING);

    if(!value)
        return NULL;
    
    length = 0;

    while(text[length])
    {
        length++;
    }
    
    value->string_value = MAlloc(
        length + 1
    );

    if(!value->string_value)
    {
        Free(value);
        return NULL;
    }

    for(i = 0; i < length; i++)
    {
        value->string_value[i] = text[i];
    }

    value->string_value[length] = 0;

    return value;
}
KSONValue *KSONCreateNumber(
    I64 number
)
{
    KSONValue *value;

    value = CreateValue(KSON_NUMBER);

    if(!value)
        return NULL;

    value->number_value = number;

    return value;
}
KSONValue *KSONCreateBoolean(
    Bool value
)
{
    KSONValue *boolean;

    boolean = CreateValue(KSON_BOOLEAN);

    if(!boolean)
        return NULL;

    boolean->number_value = value;

    return boolean;
}
U0 KSONArrayAdd(
    KSONValue *array,
    KSONValue *value
)
{
    KSONValue *current;

    if(!array)
        return;

    if(!value)
        return;

    if(array->type != KSON_ARRAY)
        return;

    value->next = NULL;

    if(!array->child)
    {
        array->child = value;
        return;
    }

    current = array->child;

    while(current->next)
    {
        current = current->next;
    }

    current->next = value;
}
U0 KSONObjectAdd(
    KSONValue *object,
    U8 *key,
    KSONValue *value
)
{
    KSONValue *current;
    I64 length;
    I64 i;

    if(!object)
        return;

    if(!value)
        return;

    if(!key)
        return;

    if(object->type != KSON_OBJECT)
        return;

    length = 0;

    while(key[length])
    {
        length++;
    }

    value->key = MAlloc(length + 1);

    if(!value->key)
        return;

    for(i = 0; i < length; i++)
    {
        value->key[i] = key[i];
    }

    value->key[length] = 0;

    value->next = NULL;

    if(!object->child)
    {
        object->child = value;
        return;
    }

    current = object->child;

    while(current->next)
    {
        current = current->next;
    }

    current->next = value;
}

KSONBuffer *KSONBufferCreate()
{
    KSONBuffer *buffer;

    buffer = MAlloc(sizeof(KSONBuffer));

    if(!buffer)
        return NULL;


    buffer->capacity = 256;
    buffer->length = 0;

    buffer->data = MAlloc(
        buffer->capacity
    );


    if(!buffer->data)
    {
        Free(buffer);
        return NULL;
    }


    buffer->data[0] = 0;


    return buffer;
}

U0 KSONBufferAppend(
    KSONBuffer *buffer,
    U8 *text
);

U0 KSONBufferAppendChar(
    KSONBuffer *buffer,
    U8 character
)
{
    U8 *newData;

    if(buffer->length + 2 >= buffer->capacity)
    {
        buffer->capacity *= 2;
        
        newData = ReAlloc(
            buffer->data,
            buffer->capacity
        );

        if(!newData)
        {
            return;
        }
    buffer->data = newData;
    }

    
    buffer->data[buffer->length] = character;

    buffer->length++;

    buffer->data[buffer->length] = 0;
}

U8 *KSONBufferFinish(
    KSONBuffer *buffer
);