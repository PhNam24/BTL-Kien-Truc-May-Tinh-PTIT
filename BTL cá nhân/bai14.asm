.model small
.stack 100h
.data
    tb1 db "Nhap so thu nhat: $"
    tb2 db 10, 10, 13, "Nhap so thu hai: $"
    tb3 db 10, 10, 13, "UCLN cua hai so la: $"
    tb4 db 10, 10, 13, "BCNN cua hai so la: $"
    num db 10 dup("$") ;xau de nhap so
    num1 db ?          ;bien de luu so thu 1
    num2 db ?          ;bien de luu so thu 2
.code                
    main proc
        mov ax, @data
        mov ds, ax
        
        ;nhap du lieu
        ;so thu nhat
        lea dx, tb1
        mov ah, 9
        int 21h
        
        lea dx, num
        mov ah, 10
        int 21h
        
        ;chuyen so thu 1 tu xau sang so
        call convertNum
        and ax, 00ffh   ;chuyen gia tri tu thanh ghi 16 bit ve 8 bit
        mov num1, al    ;luu so thu nhat vao num1
        
        ;so thu 2
        lea dx, tb2
        mov ah, 9
        int 21h
        
        lea dx, num
        mov ah, 10
        int 21h
        
        ;chuyen so thu 2 tu xau sang so
        call convertNum
        and ax, 00ffh   ;chuyen gia tri tu thanh ghi 16 bit ve 8 bit
        mov num2, al    ;luu so thu nhat vao num2 
        
        ;tim UCLN, BCNN
        
        mov cl, num1
        mov ch, num2
        
        mov dl, cl
        mov dh, ch
        
        uc:
            cmp dl, dh
            je ucend
            jg ucln
            sub dh, dl
            jmp uc
        
        ucln:
            sub dl, dh
            jmp uc
            
        ucend:
            push dx
            mov ah, 9
            lea dx, tb3
            int 21h
        
        pop dx
        xor ah, ah
        mov al, dl
        push dx
        call printNum 
        
        lea dx, tb4
        mov ah, 9
        int 21h
        
        mov al, cl
        mul ch
        
        pop dx
        div dl
        call printNum
        
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
        
    main endp
    
    ;Ham chuyen xau sang so
    convertNum proc
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
        
        ret
    convertNum endp
        
    ;ham in kq
    printNum proc
        push ax
        push bx
        push cx
        push dx
        
        mov bl, 10
        mov cx, 0
        
        lap: 
            div bl
            push ax
            inc cx
            cmp al, 0
            je catexit
            xor ah, ah
            jmp lap
            
        catexit:
            startPrint:
                pop ax
                mov dl, ah
                add dl, '0'
                mov ah, 2
                int 21h
                loop startPrint
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    printNum endp
end
                