#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
    void *a, *b, *c, *d, *e;

    iniciaAlocador();
    imprimeMapa();

    a = alocaMem(100);
    imprimeMapa();
    
    b = alocaMem(150);
    imprimeMapa();
    
    liberaMem(b);
    imprimeMapa();
    
    b = alocaMem(48);
    imprimeMapa();

    c = alocaMem(19);
    imprimeMapa();

    d = alocaMem(1);
    imprimeMapa();

    e = alocaMem(2);
    imprimeMapa();

    liberaMem(b);
    imprimeMapa();

    liberaMem(d);
    imprimeMapa();

    liberaMem(c);
    imprimeMapa();

    liberaMem(e);
    imprimeMapa();

    liberaMem(a);
    imprimeMapa();

    finalizaAlocador();

    return EXIT_SUCCESS;
}
