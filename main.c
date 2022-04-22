#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
#if 0
    int *x = NULL;
    
    iniciaAlocador();

    x = alocaMem(4);
    printf("%p\n", (void *)x);

    for (int i = 0; i < 4; ++i)
        x[i] = i;

    x = alocaMem(10);
    printf("%p\n", (void *)x);

    for (int i = 0; i < 10; ++i)
        x[i] = i;

    liberaMem(x);
    finalizaAlocador();
#else
    void *a, *b;

    iniciaAlocador();
    imprimeMapa();
    a=alocaMem(10);
    imprimeMapa();
    b=alocaMem(15);
    imprimeMapa();
    liberaMem(a);
    imprimeMapa();
    a=alocaMem(7);
    imprimeMapa();
    liberaMem(b);
    imprimeMapa();
#endif

    return EXIT_SUCCESS;
}
