.section .data
    topoInicialHeap:    .quad 0
    prevAlloc:          .quad 0
.globl topoInicialHeap
.globl prevAlloc
    str_init:           .string "Init printf() heap arena\n"
    str_cabc:           .string "################"
    plus_char:          .byte 43
    minus_char:         .byte 45

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

    subq $32, %rsp # -8(%rbp) := topo ; -16(%rbp) := tmp ;
                   # -24(%rbp) := segunda_tentativa ;
                   # -32(%rbp) := novoBloco
    movq %rdi, %r8 # num_bytes

    movq $0, %rdi
    movq $12, %rax
    syscall                         # %rax := sbrk(0)
    movq %rax, -8(%rbp)             # topo := sbrk(0)

    movq prevAlloc, %rax
    movq %rax, -16(%rbp)            # tmp := prevAlloc

    movq $0, -24(%rbp)              # segunda_tentativa := 0

    while1:
        movq -24(%rbp), %rax        # rax = segunda_tentativa
        cmpq $1, %rax
        jg fim_while1               # while (segunda_tentativa <= 1)

        while2:
            movq -16(%rbp), %rbx    # rbx = tmp
            cmpq -8(%rbp), %rbx     # while (tmp != topo)
            je fim_while2

            if1:                
                cmpq $0, (%rbx)
                jne fim_if1         # if (tmp[0] == 0)

                if2:                    
                    movq %rbx, %rcx     # rcx := tmp        (rcx) := tmp[0]
                    addq $8, %rcx       # rcx := tmp + 8    (rcx) := tmp[1]
                    cmpq %r8, (%rcx)    # if (tmp[1] >= num_bytes)
                    jl fim_if2            

                    subq $8, %rcx       # (rcx) := tmp[0]
                    movq $1, (%rcx)     # tmp[0] := 1

                    if3:               
                        addq $8, %rcx       # (rcx) := tmp[1]
                        movq %r8, %rax      # rax := num_bytes
                        addq $16, %rax      # rax := num_bytes + 16
                        cmpq %rax, (%rcx)   # if (tmp[1] >= num_bytes + 16)
                        jl fim_if3

                        movq %rbx, %rcx         # rcx := tmp
                        addq %rax, %rcx         # tmp := tmp + 16 + num_bytes
                        movq %rcx, -32(%rbp)    # novoBloco := tmp + 16 + num_bytes

                        movq $0, (%rcx)         # novoBloco[0] := 0
                        
                        addq $8, %rcx           # (rcx) := novoBloco[1]
                        addq $8, %rbx           # (rbx) := tmp[1]
                        movq (%rbx), %rax
                        movq %rax, (%rcx)     # novoBLoco[1] := tmp[1]
                        subq $16, (%rcx)        # novoBloco[1] := tmp[1] - 16
                        subq %r8, (%rcx)        # novoBloco[1] := tmp[1] - 16 - num_bytes
                        
                        movq %r8, (%rbx)        # tmp[1] := num_bytes
                    fim_if3:
                    
                    movq -16(%rbp), %rcx    # rcx := tmp
                    movq %rcx, %rbx
                    addq $8, %rbx           # (rbx) := tmp[1]
                    addq (%rbx), %rcx       # rcx := tmp + tmp[1]
                    addq $16, %rcx          # rcx := tmp + tmp[1] + 16
                    movq %rcx, prevAlloc    # prevAlloc := (long *)((char *)tmp + 16 + tmp[1])
                    
                    addq $8, %rbx           # (rbx) := tmp[2]
                    movq %rbx, %rax         # rax := &tmp[2]
                    addq $32, %rsp
                    popq %rbp
                    ret                     # return &tmp[2]
                fim_if2:
            fim_if1:

            movq -16(%rbp), %rax    # rax := tmp
            movq %rax, %rbx
            addq $8, %rbx           # (rbx) := tmp[1]
            addq (%rbx), %rax       # rax := tmp + tmp[1]
            addq $16, %rax          # rax := tmp + tmp[1] + 16
            movq %rax, -16(%rbp)    # tmp := (long *)((char *)tmp + 16 + tmp[1])
            jmp while2
        fim_while2:

        movq topoInicialHeap, %rax
        movq %rax, -16(%rbp)        # tmp := topoInicialHeap
        addq $1, -24(%rbp)          # ++segunda_tentativa

        jmp while1
    fim_while1:

    # sinaliza como ocupado e armazena tam de memória a ser alocado
    movq -8(%rbp), %rdi            # rdi := brk(0)
    addq $16, %rdi
    addq %r8, %rdi
    movq $12, %rax
    syscall
    movq %rax, prevAlloc            # prevAlloc = (long *)((char *)topo + 16 + num_bytes)

    movq -8(%rbp), %rax             # rax := topo
    movq $1, (%rax)                 # topo[0] := 1L
    addq $8, %rax                   # rax := topo + 8
    movq %r8, (%rax)                # topo[1] := num_bytes
    addq $8, %rax                   # rax := topo + 16

    addq $32, %rsp
    popq %rbp
    ret                             # return tmp

.globl liberaMem
liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp  # -8(%rbp) := topo ; -16(%rbp) := tmp ; -24(%rbp) := ret
                    # -32(%rbp) := prev ; -40(%rbp) := next ; -48(%rbp) := x

    movq %rdi, -16(%rbp)            # tmp := block
    movq $0, -24(%rbp)              # ret := 0

    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -8(%rbp)             # topo := sbrk(0)

    movq -16(%rbp), %rax
    cmpq $1, -16(%rax)              # if (tmp[-2] == 1L)
    jne fim_if4
    movq $0, -16(%rax)              # tmp[-2] := 0L
    movq $1, -24(%rbp)              # ret := 1
    fim_if4:
    
    movq topoInicialHeap, %rax
    movq %rax, -32(%rbp)            # prev := topoInicialHeap

    movq %rax, %rbx                 # rbx := prev
    addq 8(%rax), %rbx              # rbx := prev + prev[1]
    addq $16, %rbx                  # rbx := prev + 16 + prev[1]
    movq %rbx, -40(%rbp)            # next := (long *)((char *)prev + 16 + prev[1])

    while3:
        movq $0, -48(%rbp)          # x := 0

        movq -8(%rbp), %rax
        movq -40(%rbp), %rbx
        cmpq %rax, %rbx             # while (next != topo)
        je fim_while3

        while4:
            movq -32(%rbp), %rax
            movq (%rax), %rax
            cmpq $0, %rax
            jne fim_while4          # prev[0] == 0L && ...

            movq -40(%rbp), %rax
            movq (%rax), %rax
            cmpq $0, %rax
            jne fim_while4          # next[0] == 0L && ...

            movq -40(%rbp), %rax
            movq -8(%rbp), %rbx
            cmpq %rax, %rbx         # while (next != topo)
            je fim_while4

            movq -40(%rbp), %rax    # rax := next
            movq 8(%rax), %rbx      # rbx := next[1]
            movq -32(%rbp), %rax    # rbx := prev
            addq %rbx, 8(%rax)      # prev[1] += next[1]
            addq $16, 8(%rax)       # prev[1] += next[1] + 16

            movq -32(%rbp), %rax    # rax := prev
            addq 8(%rax), %rax      # rax := prev + prev[1]
            addq $16, %rax          # rax := prev + prev[1] + 16
            movq %rax, -40(%rbp)    # next = (long *)((char *)prev + 16 + prev[1])

            movq $1, -48(%rbp)      # x := 1
            jmp while4
        fim_while4:

        movq -40(%rbp), %rax
        movq %rax, -32(%rbp)        # prev = next

        cmpq $0, -48(%rbp)
        jne fim_if5                 # if (x == 0)
        movq -32(%rbp), %rax        # rax := prev
        addq 8(%rax), %rax          # rax := prev + prev[1]
        addq $16, %rax              # rax := prev + prev[1] + 16
        movq %rax, -40(%rbp)        # next := (long *)((char *)prev + 16 + prev[1])
        fim_if5:

        jmp while3
    fim_while3:

    movq -16(%rbp), %rax        # rax := tmp
    addq -8(%rax), %rax         # rax := tmp + tmp[-1]
    movq %rax, prevAlloc        # prevAlloc = (long *)(tmp[-1] + (char *)tmp)

    movq -24(%rbp), %rax
    addq $48, %rsp
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

    while5:
        movq -8(%rbp), %rax
        movq -16(%rbp), %rbx
        cmpq %rbx, %rax        # while (a != topoAtual)
        je fim_while5

        # print '################'
        movq $0, %rax
        movq $str_cabc, %rdi
        call printf

        # condicional e loop p/ printar caracteres '+' ou '-'
        movq -8(%rbp), %rax     # rax := a
        cmpq $1, (%rax)
        jne minus_sign          # se a[0] == 0 vai pra minus_sign

        mov plus_char, %r10     # r10 = '+'
        movq $0, %r11           # r11 := i = 0
        jmp for1

        minus_sign:
        mov minus_char, %r10    # r10 = '-'
        movq $0, %r11           # r11 := i = 0

        for1:
            movq -8(%rbp), %rax     # rax := a
            addq $8, %rax           # (rax) := a[1]
            cmpq (%rax), %r11       # for (int i = 0; i < a[1]; i++)
            jge fim_for1

            movq %r10, %rdi
            call putchar            # printa + ou -

            addq $1, %r11           # i++

            jmp for1
        fim_for1:

        movq -8(%rbp), %rbx     # rbx := a
        movq -8(%rbp), %rax
        addq $8, %rax           # (rax) := a[1]
        addq (%rax), %rbx       # rbx := a + a[1]
        addq $16, %rbx          # rbx := a+ a[1] + 16
        movq %rbx, -8(%rbp)     # a := (long *)((char *)a + 16 + a[1])

        jmp while5
    fim_while5:

    movq $10, %rdi  # char de fim de linha
    call putchar
    movq $10, %rdi  # char de fim de linha
    call putchar

    addq $24, %rsp
    popq %rbp
    ret
