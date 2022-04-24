#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
    void *a, *b, *c, *d;

    iniciaAlocador();
    imprimeMapa();

    a = alocaMem(100);
    // printf("%p\n", a);
    imprimeMapa();
    
    b = alocaMem(150);
    // printf("%p, %ld\n", b, b - a);
    imprimeMapa();
    
    liberaMem(b);
    imprimeMapa();
    
    b = alocaMem(50);
    // printf("%p, %ld\n", b, b - a);
    imprimeMapa();

    c = alocaMem(30);
    // printf("%p, %ld\n", c, c - b);
    imprimeMapa();

    d = alocaMem(38);
    // printf("%p, %ld\n", d, d - c);
    imprimeMapa();
    
    liberaMem(a);
    imprimeMapa();

    liberaMem(c);
    imprimeMapa();

    liberaMem(b);
    imprimeMapa();

    liberaMem(d);
    imprimeMapa();

    return EXIT_SUCCESS;
}
