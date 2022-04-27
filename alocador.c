#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

static void *topoInicialHeap;
static long *prevAlloc;

void iniciaAlocador(void)
{
    printf("Init printf() heap arena\n");
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

                /* verifica se é possível particionar o bloco */
                if (tmp[1] >= num_bytes + 16) {
                    long *novoBloco = (long *)((char *)tmp + 16 + num_bytes);
                    novoBloco[0] = 0L;
                    novoBloco[1] = tmp[1] - num_bytes - 16;
                    
                    tmp[1] = num_bytes;
                }
                prevAlloc = (long *)((char *)tmp + 16 + tmp[1]);
                return &tmp[2];
            }
            tmp = (long *)((char *)tmp + 16 + tmp[1]);
        }
        tmp = topoInicialHeap;
        ++segunda_tentativa;
    }

    /* sinaliza como ocupado e armazena tam de memória a ser alocado */
    brk((char *)topo + 16 + num_bytes);
    topo[0] = 1L;
    topo[1] = num_bytes;

    prevAlloc = (long *)((char *)topo + 16 + num_bytes);

    return &topo[2];
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
        int x = 0;
        while (prev[0] == 0L && next[0] == 0L && next != topo) {
            prev[1] = prev[1] + next[1] + 16;
            next = (long *)((char *)prev + 16 + prev[1]);
            x = 1;
        }
        prev = next;
        if (x == 0)
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
    putchar('\n');
}
