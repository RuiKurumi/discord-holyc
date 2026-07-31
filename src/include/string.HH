#ifndef STRING_HH
#define STRING_HH

Bool StrContains(
    U8 *haystack,
    U8 *needle
);

I32 StrCompare(
    U8 *a,
    U8 *b
);

U8 *StrCopy(
    U8 *source
);

#endif