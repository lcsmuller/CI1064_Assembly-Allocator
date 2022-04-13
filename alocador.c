#include <unistd.h>

static void *topoInicialHeap;

void iniciaAlocador(void)
{
    topoInicialHeap = sbrk(0);
}

void finalizaAlocador(void)
{
    brk(topoInicialHeap);
}

void *alocaMem(int num_bytes)
{
    void *tmp = sbrk(0);
    brk(tmp + num_bytes);
    return tmp;
}

int liberaMem(void *block)
{
}
