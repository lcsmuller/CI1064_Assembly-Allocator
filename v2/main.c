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
    void *a, *b, *c, *d;

    iniciaAlocador();
    imprimeMapa();

    a = alocaMem(100);
    imprimeMapa();
    
    b = alocaMem(150);
    imprimeMapa();
    
    liberaMem(b);
    imprimeMapa();
    
    b = alocaMem(50);
    imprimeMapa();

    c = alocaMem(30);
    imprimeMapa();

    d = alocaMem(38);
    imprimeMapa();
    
    liberaMem(a);
    imprimeMapa();

    liberaMem(c);
    imprimeMapa();

    liberaMem(b);
    imprimeMapa();

    liberaMem(d);
    imprimeMapa();

#endif

    return EXIT_SUCCESS;
}
