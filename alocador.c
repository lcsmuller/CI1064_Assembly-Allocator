#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

static void *topoInicialHeap;
static long *prevAlloc;

void iniciaAlocador(void)
{
    printf("\n");
    prevAlloc = topoInicialHeap = sbrk(0);
}

void finalizaAlocador(void)
{
    brk(topoInicialHeap);
}

void *alocaMem(int num_bytes)
{
    long *topo = sbrk(0), *tmp = prevAlloc;
    long segunda_tentativa = 0L;

    while (segunda_tentativa <= 1) {
        while (tmp != topo) {
            if (tmp[0] == 0L && tmp[1] >= num_bytes) {
                tmp[0] = 1L;
                tmp = (long *)((char *)tmp + 16 + tmp[1]);
                prevAlloc = tmp;
                return &tmp[2];
            }
            tmp = (long *)((char *)tmp + 16 + tmp[1]);
        }
        tmp = topoInicialHeap;
        ++segunda_tentativa;
    }

    /* sinaliza como ocupado e armazena tam de memória a ser alocado */
    tmp = sbrk(16);
    tmp[0] = 1L;
    tmp[1] = num_bytes;
    /* aloca espaço de memória requisitado */
    tmp = sbrk(num_bytes);

    prevAlloc = (long *)(num_bytes + (char *)tmp);

    return tmp;
}

int liberaMem(void *block)
{
    long *topo = sbrk(0), *tmp = block;
    int ret = 0;

    if (tmp[-2] == 1L) {
        tmp[-2] = 0L;
        ret = 1; 
    }

    long *prev = topoInicialHeap; 
    long *next = (long *)((char *)prev + 16 + prev[1]);
    while (next != topo) {
        if (prev[0] == 0L && next[0] == 0L)
            prev[1] += next[1] + 16;
        prev = next;
        next = (long *)((char *)prev + 16 + prev[1]);
    }

    prevAlloc = (long *)(tmp[-1] + (char*)tmp);
    return ret;
}

void imprimeMapa()
{
    long *a = topoInicialHeap;
    void *topoAtual = sbrk(0);
    char c;

    printf("imprimindo............\n");
    while (a != topoAtual){
        printf("################");
        if (a[0] == 1)
            c = '+';
        else
            c = '-';
        for(int i = 0; i < a[1]; i++)
            putchar(c);

        a = (long *)((char *)a + 16 + a[1]);
    }
    putchar('\n');
}
