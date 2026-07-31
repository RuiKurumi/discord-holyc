#include "../include/string.HH"

Bool StrContains(
    U8 *haystack,
    U8 *needle
)
{
    I64 i;
    I64 j;

    if(!haystack || !needle)
        return FALSE;

    for(i = 0; haystack[i]; i++)
    {
        j = 0;

        while(
            needle[j] &&
            haystack[i+j] == needle[j]
        )
        {
            j++;
        }

        if(!needle[j])
            return TRUE;
    }

    return FALSE;
}
I32 StrCompare(
    U8 *a,
    U8 *b
)
{
    while(*a && *b)
    {
        if(*a != *b)
            return *a - *b;

        a++;
        b++;
    }

    return *a - *b;
}