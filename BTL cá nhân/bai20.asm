.model small
.stack 100h
.data
    tb1 db 'Chuoi A la: $'
    tb2 db 10, 13, 10, 'Chuoi B la: Nam$'
    tb3 db 10, 13, 10, 'So lan xuat hien cua chuoi B trong chuoi A la: $'
    a db 'Pham Hoai Nam B21DCCN554 PTIT Nam dep trai$'
    count dw ?
.code 
main proc
     mov ax, @data
     mov ds, ax
     
     ;in ra xau A, xau B da cho
     lea dx, tb1
     mov ah, 9
     int 21h     
     
     lea dx, a
     mov ah, 9
     int 21h
     
     lea dx, tb2
     mov ah, 9
     int 21h
     
     
     ;dem so lan xuat hien
     mov count, 0
     xor cx, cx
     lea si, a + 1
     mov cl, [si]
     inc si
     lap:
        ;kiem tra chu N
        mov dl, [si]
        cmp dl, 'N'
        jne next
        inc si
        dec cx
        cmp cx, 0
        je inkq
        
        ;kiem tra chu a
        mov dl, [si]
        cmp dl, 'a'
        jne next
        inc si
        dec cx
        cmp cx, 0
        je inkq
        
        ;kiem tra chu m
        mov dl, [si]
        cmp dl, 'm'
        jne next
        inc si
        dec cx
        cmp cx, 0
        je dem
        
        dem:
            inc count
            cmp cx, 0
            je inkq
            
        next:
            inc si
            dec cx
            cmp cx, 0
            jne lap
            
        inkq:
            mov ah, 9
            lea dx, tb3
            int 21h
            
            call printNumber
            
     ;dung chuong trinh
     mov ah, 4ch
     int 21h
     
main endp

;ham in so
printNumber proc
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
        
    ;lap2 de in kq
    lap2:
        pop dx
        add dx, '0'
        mov ah, 2
        int 21h
    loop lap2
    ret
printNumber endp
end