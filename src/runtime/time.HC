#include "../include/time.HH"


extern "c" I64 time(U0 *ptr);

I64 TimeNow()
{
    return time(NULL);
}
