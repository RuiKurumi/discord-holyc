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
    U8 *json;


    root = KSONParse(
    "[1,2,3]"
    );

    json = KSONStringify(root);

    Print(json);
   

    if(!root)
    {
        Print("Parse failed\n");
        return 1;
    }

    

    Print("Parse succeeded\n");


    json = KSONStringify(root);


    if(!json)
    {
        Print("Stringify failed\n");

        KSONFree(root);

        return 1;
    }

    Print("\n");


    KSONFree(root);


    return 0;
}