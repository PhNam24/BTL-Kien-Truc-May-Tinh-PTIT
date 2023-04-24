.model small
.stack 100h
.data
    tb1 db "Nhap xau ky tu: $"
    tb2 db 10, 10, 13, "Xau ky tu sau khi dao nguoc la: $"
    string db 256 dup("$")
.code
    main proc
        mov ax, @data
        mov ds, ax
        
        ;nhap xau 
        lea dx, tb1
        mov ah, 9
        int 21h
        
        lea dx, string
        mov ah, 10
        int 21h 
        
        ;Dao nguoc xau
        lea dx, tb2
        mov ah, 9
        int 21h
        
        xor cx, cx
        mov cl, string+1
        lea si, string+2
        lap1:
            push [si]
            inc si
            loop lap1
            
        mov cl, string + 1
        lap2:
            pop dx
            mov ah, 2
            int 21h
            loop lap2 
        
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
    main endp
end
        
        