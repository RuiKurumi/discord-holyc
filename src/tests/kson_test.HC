#include "../include/kson.HH"
#include "../json/kson.HC"
#include "../include/print.HH"

extern "c" I32 snprintf(
    U8 *str,
    U64 size,
    U8 *fmt,
    ...
);

I32 Main(I32 argc, U8 **argv)
{
   
    KSONValue *value;
    U8 *json;

    /* Boolean */

    value = KSONCreateBoolean(TRUE);

    json = KSONStringify(value);

    Print(json);
    Print("\n");

    Free(json);
    KSONFree(value);

    /* Null */

    value = KSONCreateNull();

    json = KSONStringify(value);

    Print(json);
    Print("\n");

    Free(json);
    KSONFree(value);

    return 0;
} //practically speaking I'm just having a very complex
// masochism exercise