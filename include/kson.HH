#ifndef KSON_HH
#define KSON_HH

#define KSON_NULL      0
#define KSON_OBJECT    1
#define KSON_STRING    2
#define KSON_NUMBER    3
#define KSON_BOOLEAN   4
#define KSON_ARRAY     5

class KSONValue
{
    I64 type;

    U8 *string_value;
    I64 number_value;

    KSONValue *child;
    KSONValue *next;

    U8 *key;
};

class KSONBuffer
{
    U8 *data;
    I64 length;
    I64 capacity;

};

KSONValue *KSONParse(
    U8 *text
);

KSONValue *KSONGet(
    KSONValue *object,
    U8 *key
);

U8 *KSONStringify(
    KSONValue *value
);

U0 KSONFree(
    KSONValue *value
);
//KSON still
KSONValue *KSONCreateObject();

KSONValue *KSONCreateArray(
    KSONValue *array,
    KSONValue *value
);

KSONValue *KSONCreateString(
    U8 *text
);

KSONValue *KSONCreateNumber(
    I64 value
);

KSONValue *KSONCreateBoolean(
    Bool value
);

KSONValue *KSONCreateNull();


U0 KSONObjectAdd(
    KSONValue *object,
    U8 *key,
    KSONValue *value
); 

U0 KSONArrayAdd(
    KSONValue *array,
    KSONValue *value
    //at least it isn't a queue bruh
);



KSONBuffer *KSONBufferCreate();


U0 KSONBufferAppend(
    KSONBuffer *buffer,
    U8 *text
);

U0 KSONBufferAppendChar(
    KSONBuffer *buffer,
    U8 character
);

U8 *KSONBufferFinish(
    KSONBuffer *buffer
);

#endif