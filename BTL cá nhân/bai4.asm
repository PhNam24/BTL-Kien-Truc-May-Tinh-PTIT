.model small
.stack 100h
.data
    tb1 db "Nhap ky tu viet thuong: $"
    tb2 db 10, 10, 13, "Ky tu in hoa la: $" 
    char db ?
.code 
    main proc
        mov ax, @data
        mov ds, ax
        
        ;nhap ky tu
        lea dx, tb1
        mov ah, 9
        int 21h
        
        mov ah, 1
        int 21h
        mov char, al
        
        sub char, 32
        
        ;in ket qua
        lea dx, tb2
        mov ah, 9
        int 21h
        
        mov dl, char
        mov ah, 2
        int 21h
        
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
    main endp
end