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
    KSONValue *root;

    root = KSONParse("\"Hello DiscordHC\"");

    if(!root)
    {
        Print("Parse failed\n");
        return 1;
    }

    Print(root->string_value);
    Print("\n");

    KSONFree(root);

    U8 output[64];

    snprintf(
        output,
        sizeof(output),
        "Parsed number: %lld\n",
        root->number_value
    );
    Print(output);

    return 0;
}