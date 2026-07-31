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

#endif