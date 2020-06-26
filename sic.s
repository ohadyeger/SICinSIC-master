
    section .data
    
    MAX_PHYSICAL_MEMORY: dq 4096 
    scan_format: db "%ld",10,0
    print_format: db "%d ",10,0
    print_format2: db "%d ",10,0
    
    section .bss
    
    M: resq 4096
    mem:    resq 1
    n:      resq 1
    i:      resq 1
        
    section .text
  
        global main
        extern malloc
        extern calloc
        extern free
        extern scanf
        extern printf
        extern exit
        
        
%macro print_f 1 ;in the this macro we expect 
                                 ; that the number to be printed is in the
        jmp %%L
    
    %%M:
        db %1
    %%L:
       mov rdi,%%M
       mov rax,0
       call printf
       
%endmacro

main:
        push	rbp
	mov	rbp,   rsp 
	
	mov qword[n],0
	mov qword[i],0
	xor r12, r12
	xor r11, r11 
	
    scanfing:
        
        
        mov rdi, scan_format	
        mov rsi, qword M
        add rsi, r12 ; M[i]
        mov rax, 0
        call scanf
        cmp rax, 1
        jne mallocing

        add r12, 8  ;i++
        inc qword[n]     ;n++
        ;print_f {"hello",10,0}
        jmp scanfing
        
    mallocing:
        ;jmp print_the_memory
        mov rax, qword[n]   ; rax = n
        shl rax, 3          ; rax = n*sizeof long
        mov rdi, rax        ; rdi = n*sizeof long
        mov rax, 0  
        call malloc
        mov qword[mem], rax ;long *mem = (long*)malloc(n*sizeof(long));
        
        xor r9, r9 ;i=0
        
    copy:
        
        cmp r9, qword[n]    ;i<n?
        jge next         ;false: next
        mov rax, r9
        shl rax, 3          ;rax = i*8
        mov r10, M          ;r10 = M[0]
        add r10, rax        ;r10 = M[i]
        mov r11, qword [r10];r11 = [M[i]]
        mov r8, qword[mem]  ;r8 = mem
        add r8, rax         ;r8 = mem + i*8
        mov qword [r8], r11 ;m[i] = [M[i]]
        
        
        inc r9
        
        jmp copy
    next:
        ;jmp print_the_memory
        xor r12,r12 ; i = 0
        
        xor rax,rax ; zero rax
        
    loop_it:
        
        
        mov r10, qword [mem] ;r10 = *mem
        mov rax,r12           ;rax = i
        shl rax,3            ;rax = i*8
        add r10,rax          ;r10 = mem+i*8
        mov rdi, qword [r10] ;rdi = mem[i*8]
        ;add rax, 8           
        add r10 , 8          ;r10 = mem+8*(i+1)
        mov rsi, qword [r10] ;rsi = mem[i+1]
        ;add rax, 8
        add r10, 8           ;r10 = mem+8*(i+2)
        mov rdx , qword [r10] ;rdx = mem[i+2]
       
       ; mem[mem[i]
        

        mov rcx,rdi     ;rcx = mem[i]
        or rcx, rsi     ;rcx = mem[i] | mem[i+1]
        or rcx, rdx     ;rcx = mem[i]|mem[i+1]|mem[i+2]
        
        cmp rcx,0
        je print_the_memory
        
        shl rdi,3
        shl rsi,3
        mov r10 , qword [mem]   ;r10 = *mem
        add r10, rdi ; r10 = mem + mem[i*8]
        mov r11 , qword [mem]   ;r11 = *mem
        add r11, rsi            ;r11 = mem + (i+1)*8
        mov rax , qword [r10]   ;rax = [mem + [mem[i*8]]]
        sub rax, qword [r11]
        mov qword [r10], rax
        ;;mov r13, qword [r10] ; r15 = difference
        ;mov r14, qword [r11] ; r15 = difference
        
        
        cmp rax,0
        jge else
        
        mov r12, rdx
        jmp loop_it
        
        else:
            add r12,3
            jmp loop_it
        
        
        
    print_the_memory:
        xor r12,r12
        .print_loop:
            cmp r12,qword [n]
            jge end
            mov rdi,print_format
            mov r10, qword [mem]
            mov rax, r12
            shl rax,3
            add r10,rax
            mov rsi, qword [r10]
            xor rax, rax
            call printf
            inc r12
            jmp .print_loop
            
        
        
	
    end:
        mov rdi, qword [mem]
        call free
        
        mov     rsp, rbp
        pop     rbp
        ret 

        
        