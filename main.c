#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
    int *x;
    
    iniciaAlocador();

    x = alocaMem(256);
    for (int i = 0; i < 256; ++i)
        x[i] = i;
#if 0
    liberaMem(x);
    finalizaAlocador();
#endif

    return EXIT_SUCCESS;
}
