.section .data
    topoInicialHeap: .quad 0
    prevAlloc: .quad 0
str_init: .string "Init printf() heap arena\n"
str_info: .string "imprimindo ...\n"
str_cabc: .string "################\n"

.section .text

.globl iniciaAlocador
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Inicializa buffer do printf() alocado na heap
    movq $0, %rax              # parâmetros variádicos printf (nulo)
    movq $str_init, %rdi       # primeiro parâmetro printf
    call printf

    # Obtêm topo inicial da heap
    movq $0, %rdi              # primeiro parâmetro brk
    movq $12, %rax             # No de syscall do brk
    syscall                    # brk(0)
    movq %rax, topoInicialHeap # topo da heap (retorno de brk)
    movq %rax, prevAlloc       # prevAlloc := topoInicialHeap

    popq %rbp
    ret

.globl finalizaAlocador
finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq topoInicialHeap, %rdi # primeiro parâmetro brk
    movq $12, %rax             # No de syscall do brk
    syscall
    movq %rax, topoInicialHeap # topo da heap (retorno de brk)

    popq %rbp
    ret

.globl alocaMem
alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp # -8(%rbp) := topo ; -16(%rbp) := tmp ;
                   # -24(%rbp) := segunda_tentativa
    movq %rdi, %r8 # num_bytes

    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -8(%rbp)             # topo := sbrk(0)
    movq prevAlloc, %rax
    movq %rax, -16(%rbp)            # tmp := prevAlloc
    movq $0, -24(%rbp)              # segunda_tentativa := 0

    L0:
        movq -24(%rbp), %rax
        cmpq $1, %rax
        jg EL0                      # while (segunda_tentativa <= 1)

        L1:
            movq -8(%rbp), %rax
            movq -16(%rbp), %rbx
            cmpq %rax, %rbx         # while (tmp != topo)
            je EL1

            # TODO: if (tmp[0] == 0L && tmp[1] >= num_bytes)

            movq -16(%rbp), %rax
            movq 8(%rax), %rax     # %rax := tmp[1]
            addq $16, %rax         # %rax := tmp[1] + 16
            addq %rax, -16(%rbp)   # tmp := (long *)((char *)tmp + 16 + tmp[1])
            jmp L1
        EL1:

        movq topoInicialHeap, %rax
        movq %rax, -16(%rbp)       # tmp := topoInicialHeap
        addq $1, -24(%rbp)         # ++segunda_tentativa

        jmp L0
    EL0:

    # sinaliza como ocupado e armazena tam de memória a ser alocado
    movq $16, %rdi
    movq $12, %rax
    syscall
    movq %rax, -16(%rbp)           # tmp := sbrk(16)
    movq -16(%rbp), %rax
    movq $1, (%rax)                # tmp[0] := 1L
    movq %r8, %rbx
    movq %rbx, 8(%rax)             # tmp[8] := num_bytes
    # aloca espaço de memória requisitado
    movq %rbx, %rdi
    movq $12, %rax
    syscall
    movq %rax, -16(%rbp)           # tmp := sbrk(num_bytes)

    addq -16(%rbp), %rbx
    movq %rbx, prevAlloc           # prevAlloc = (long *)(num_bytes + tmp)

    movq -16(%rbp), %rax
    addq $24, %rsp
    popq %rbp
    ret                            # return tmp

.globl liberaMem
liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $40, %rsp # -8(%rbp) := topo ; -16(%rbp) := tmp ; -24(%rbp) := ret
                   # -32(%rbp) := prev ; -40(%rbp) := next

    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -8(%rbp)             # topo := sbrk(0)
    movq %rdi, %rax
    movq %rax, -16(%rbp)            # tmp := block
    movq $0, -24(%rbp)              # ret := 0
    movq topoInicialHeap, %rax
    movq %rax, -32(%rbp)            # prev := topoInicialHeap
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    movq 8(%rax), %rax              # %rax := prev[1]
    addq $16, %rax                  # %rax := 16 + prev[1]
    addq %rax, -40(%rbp)            # next := prev + 16 + prev[1]

    movq -16(%rbp), %rax
    movq -16(%rax), %rax
    movq $1, %rbx
    cmpq %rax, %rbx            # if (tmp[-2] != 1)
    jne EIF0
        movq $0, -16(%rax)     # tmp[-2] := 0
        movq $1, -24(%rbp)     # ret := 1
    EIF0:

    # TODO: loop while
    # L2:
    #     movq -32(%rbp), %rax
    #     movq -40(%rbp), %rbx
    #     cmpq %rbx, %rax        # while (prev != next)
    #     je EL2
    #
    #     jmp L2
    # EL2:

    movq -16(%rbp), %rax
    movq -8(%rax), %rax
    addq -16(%rbp), %rax
    movq %rax, prevAlloc       # prevAlloc = (long *)(tmp[-1] + (char *)tmp)

    movq -24(%rbp), %rax
    addq $40, %rsp
    popq %rbp
    ret                        # return ret

.globl imprimeMapa
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp # -8(%rbp) := a ; -16(%rbp) := topoAtual ; -24(%rbp) := c

    movq topoInicialHeap, %rax
    movq %rax, -8(%rbp)        # a := topoInicialHeap
    movq $0, %rdi              # primeiro parâmetro brk
    movq $12, %rax             # No de syscall do brk
    syscall                    # brk(0)
    movq %rax, -16(%rbp)       # topoAtual := sbrk(0)

    # print 'imprimindo ...'
    movq $0, %rax
    movq $str_info, %rdi
    call printf
    L3:
        movq -8(%rbp), %rax
        movq -16(%rbp), %rbx
        cmpq %rbx, %rax        # while (a != topoAtual)
        je EL3

        # print '################'
        movq $0, %rax
        movq $str_cabc, %rdi
        call printf

        # TODO: condicional e loop p/ printar caracteres '+' ou '-'

        movq -8(%rbp), %rax
        movq 8(%rax), %rax     # %rax := a[1]
        addq $16, %rax         # %rax := a[1] + 16
        addq %rax, -8(%rbp)    # a := (long *)((char *)a + 16 + a[1])

        jmp L3
    EL3:

    addq $24, %rsp
    popq %rbp
    ret
