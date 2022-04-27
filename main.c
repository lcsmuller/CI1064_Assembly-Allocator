#include <stdio.h>
#include <stdlib.h>

#include "alocador.h"

int main(void)
{
#if 1
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
#else
    void *a,*b ,*c, *d, *e, *f;
    int *coisa[50];

    iniciaAlocador();

    for (int i = 0; i < 50; ++i){
        coisa[i] = (int*) alocaMem(i*sizeof(int));   
        printf("aqui tem %i \n" ,i);
        fflush(stdout);  
        imprimeMapa();
    }

    for (int i = 0; i < 50; i+= 2){
        liberaMem(coisa[i]);   
        printf("aqui liberamos %i \n" ,i);
        fflush(stdout);  
        imprimeMapa();
    }

    for (int i = 1; i < 50; i+= 2){
        liberaMem(coisa[i]);   
        printf("aqui liberamos %i \n" ,i);
        fflush(stdout);  
        imprimeMapa();
    }

    finalizaAlocador();
#endif

    return EXIT_SUCCESS;
}
