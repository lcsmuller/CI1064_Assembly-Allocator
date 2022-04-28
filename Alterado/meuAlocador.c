#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

static void *topoInicialHeap;

void iniciaAlocador(void)
{
    printf("Init printf() heap arena\n");
    topoInicialHeap = sbrk(0);
}

void finalizaAlocador(void)
{
    brk(topoInicialHeap);
}

void *alocaMem(int num_bytes)
{
    long *topo = sbrk(0), *tmp = topoInicialHeap, *maior = tmp;

    while (tmp != topo && (maior[0] == 1 && tmp[0] == 1))
        tmp = (long *)((char *)tmp + 16 + tmp[1]);
    maior = tmp;

    while (tmp != topo) {
        if (tmp[0] == 0L && tmp[1] > maior[1])
            maior = tmp;
        tmp = (long *)((char *)tmp + 16 + tmp[1]);
    }

    if (maior != topo && (maior[1] >= num_bytes + 16)) {
        maior[0] = 1L;
        return &maior[2];
    }

    /* sinaliza como ocupado e armazena tam de memória a ser alocado */
    brk((char *)topo + 16 + num_bytes);
    topo[0] = 1L;
    topo[1] = num_bytes;

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

    return ret;
}

void imprimeMapa(void)
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
