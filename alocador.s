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

.globl liberaMem
liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp # -8(%rbp) := topo ; -16(%rbp) := tmp ; -32(%rbp) := ret
                   # -40(%rbp) := prev ; -48(%rbp) := next

    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -8(%rbp)             # topo := sbrk(0)
    movq 16(%rbp), %rax
    movq %rax, -16(%rbp)            # tmp := block
    movq $0, -32(%rbp)              # ret := 0
    movq topoInicialHeap, %rax
    movq %rax, -40(%rbp)            # prev := topoInicialHeap
    movq %rax, -48(%rbp)
    movq -40(%rbp), %rax
    movq 8(%rax), %rax              # %rax := prev[1]
    addq $16, %rax                  # %rax := 16 + prev[1]
    addq %rax, -48(%rbp)            # next := prev + 16 + prev[1]

    movq -16(%rbp), %rax
    movq -16(%rax), %rax
    movq $1, %rbx
    cmpq %rax, %rbx            # if (tmp[-2] != 1)
    jne if_end
        movq $0, -2(%rax)      # tmp[-2] := 0
        movq $1, -32(%rbp)     # ret := 1
    if_end:

    # TODO: loop while
    # TODO: prevAlloc = (long *)(tmp[-1] + (char *)tmp)

    addq $48, %rsp
    popq %rbp
    ret

.globl imprimeMapa
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp # -8(%rbp) := a ; -16(%rbp) := topoAtual ; -32(%rbp) := c

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
    while:
        movq -8(%rbp), %rax
        movq -16(%rbp), %rbx
        cmpq %rbx, %rax        # while (a != topoAtual)
        je fim_while

        # print '################'
        movq $0, %rax
        movq $str_cabc, %rdi
        call printf

        # TODO: condicional e loop p/ printar caracteres '+' ou '-'

        movq -8(%rbp), %rax
        movq 8(%rax), %rax     # %rax := a[1]
        addq $16, %rax         # %rax := a[1] + 16
        addq %rax, -8(%rbp)    # a := (long *)((char *)a + 16 + a[1])

        jmp while
    fim_while:

    addq $32, %rsp
    popq %rbp
    ret
