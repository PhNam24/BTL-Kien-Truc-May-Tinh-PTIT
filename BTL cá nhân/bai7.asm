.model small
.stack 100h
.data
    tb1 db "Nhap so thap phan: $"
    tb2 db 10, 10, 13, "So o dang nhi phan la: $"
    num db 10 dup("$") ;xau de luu so thap phan
.code 
    main proc
        
        mov ax, @data
        mov ds, ax
        
        ;nhap so
        lea dx, tb1
        mov ah, 9
        int 21h
        
        lea dx, num
        mov ah, 10
        int 21h
        
        mov ax, '#'
        push ax
        
        ;chuyen xau sang so
        mov ax, 0
        mov bx, 10
        
        xor cx, cx
        mov cl, num + 1
        lea si, num + 2
        
        thapPhan:
            mul bx
            mov dl, [si]
            sub dl, '0'
            add ax, dx
            inc si
            loop thapPhan
            
        ;chuyen so thap phan sang nhi phan
        mov cl, 2
        
        nhiPhan:
            mov ah, 0
            div cl
            push ax
            cmp al, 0
            jne nhiPhan
            
        lea dx, tb2
        mov ah, 9
        int 21h
        
        inKq:
            pop dx
            cmp dx, '#'
            je ketThuc
            mov dl, dh
            add dl, '0'
            mov ah, 2
            int 21h
            jmp inKq
        
        ketThuc:
            mov ah, 4ch
            int 21h
    main endp
end
            