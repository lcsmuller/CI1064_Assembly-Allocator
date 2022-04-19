#include <unistd.h>

static void *topoInicialHeap;
static long *prevAlloc;

void iniciaAlocador(void)
{
    prevAlloc = topoInicialHeap = sbrk(0);
}

void finalizaAlocador(void)
{
    brk(topoInicialHeap);
}

void *alocaMem(int num_bytes)
{
    long *topo = sbrk(0), *tmp;

    for (int segunda = 0; segunda <= 1; ++segunda) {
        while (prevAlloc != topo) {
            if (prevAlloc[0] == 0L) {
                tmp = prevAlloc;
                tmp[0] = 1L;
                prevAlloc += 2 + prevAlloc[1];
                return &tmp[2];
            }
            prevAlloc += 2 + prevAlloc[1];
        }
        prevAlloc = topoInicialHeap;
    }

    /* sinaliza como ocupado e armazena tam de memória a ser alocado */
    tmp = sbrk(16);
    tmp[0] = 1L;
    tmp[1] = num_bytes;
    /* aloca espaço de memória requisitado */
    tmp = sbrk(num_bytes);

    prevAlloc = sbrk(0);

    return tmp;
}

int liberaMem(void *block)
{
}
