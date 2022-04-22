#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
    iniciaAlocador();
#if 0
    int *x = NULL;
    
    x = alocaMem(4);
    printf("%p\n", (void *)x);

    for (int i = 0; i < 4; ++i)
        x[i] = i;

    x = alocaMem(10);
    printf("%p\n", (void *)x);

    for (int i = 0; i < 10; ++i)
        x[i] = i;

    liberaMem(x);
#else
    void *a, *b;

    imprimeMapa();
#if 0
    a=alocaMem(10);
    imprimeMapa();
    b=alocaMem(15);
    imprimeMapa();
    
    b = alocaMem(150);
    imprimeMapa();
    
    liberaMem(a);
    imprimeMapa();
#endif
#endif
    finalizaAlocador();

    return EXIT_SUCCESS;
}
