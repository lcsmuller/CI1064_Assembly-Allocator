#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
    void *a, *b, *c, *d;

    iniciaAlocador();
    imprimeMapa();

    a = alocaMem(100);
    imprimeMapa();
    
    b = alocaMem(150);
    //imprimeMapa();
    
    liberaMem(b);
    //imprimeMapa();
    
    b = alocaMem(50);
    //imprimeMapa();

    c = alocaMem(30);
    //imprimeMapa();

    d = alocaMem(38);
    //imprimeMapa();
    
    liberaMem(a);
    //imprimeMapa();

    liberaMem(c);
    //imprimeMapa();

    liberaMem(b);
    //imprimeMapa();

    liberaMem(d);
    //imprimeMapa();

    return EXIT_SUCCESS;
}
