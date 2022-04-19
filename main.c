#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
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

    return EXIT_SUCCESS;
}
