.model small
.stack 100h
.data
    tb db 10, 10, "PHAM HOAI NAM : 24-8-2003$"      ;phan 1
    ten db "PHAMHOAINAM$"                               ;bien luu ten
    ;A = 11 + 6 = 17
    ;A mod 4 = 1 => Tinh so nhan cach
    tb1 db 10, 10, 13, "SO NHAN CACH la $"                     
    count dw ?                          
.code
    main proc
        mov ax, @data
        mov ds, ax
        
        ;in dap an
        lea dx, tb
        mov ah, 9
        int 21h
        
        lea dx, tb1
        mov ah, 9
        int 21h
        
        ;tinh toan
        mov count, 0
        lea si, ten
        xor cx, cx
        ;Nguyen am trong "PHAM HOAI NAM" : O A I
        ;Phu am trong "PHAM HOAI NAM" : P H M N
        lap:
            mov dl, [si]        ;Gan phan tu thu si vao dl 
          
            cmp dl, 'P'         ;so sanh voi P
            je tinhP
            cmp dl, 'H'         ;so sanh voi H
            je tinhH
            cmp dl, 'M'         ;so sanh voi M
            je tinhM            
            cmp dl, 'N'         ;so sanh voi N
            je tinhN            
            inc si
            cmp dl, '$'
            jne lap
                
  
        calc:        
            cmp count, 10
            ja NhanCach
            jb inkq
            
        
        endCT:
            mov ah, 4ch
            int 21h
        
        tinhP:
            add count, 7
            inc si
            jmp lap
            
        tinhH:
            add count, 8
            inc si
            jmp lap
            
        tinhM:
            add count, 4
            inc si 
            jmp lap
            
        tinhN:
            add count, 5
            inc si
            jmp lap
            
        inkq:
            call printNumber
            jmp endCT            
    main endp
    
    ;ham tinh so nhan cach
    NhanCach proc
        ;khoi tao
        mov bx, 10
        mov ax, count
        mov cx, 0
    
        ;lap1 de push vao stack
        lap1:
            mov dx, 0
            div bx
            push dx
            inc cx
            cmp ax, 0
            jnz lap1
        
        mov ax, 0
        ;lap2 de tinh tong chu so
        lap2:
            pop dx
            add ax, dx
        loop lap2
        ;tra lai gia tri cho count
        mov count, ax
        jmp calc
    ret
    NhanCach endp
    
    ;ham in so
    printNumber proc
    ;khoi tao
    mov bx, 10
    mov ax, count
    mov cx, 0
    
    ;lap1 de push vao stack
    lap3:
        mov dx, 0
        div bx
        push dx
        inc cx
        cmp ax, 0
        jnz lap1
        
    ;lap2 de in kq
    lap4:
        pop dx
        add dx, '0'
        mov ah, 2
        int 21h
    loop lap2
    ret
printNumber endp
end
    