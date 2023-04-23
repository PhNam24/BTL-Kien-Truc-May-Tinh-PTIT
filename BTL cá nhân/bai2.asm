.model small
.stack 100h
.data
    tb1 db "Nhap ky tu: $"
    tb2 db 10, 10, 13, "Ky tu vua nhap la: $"
    kyTu db ?
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
        
        mov kyTu, al
        
        ;in ra ky tu vua nhap
        lea dx, tb2
        mov ah, 9
        int 21h
                
        mov dl, kyTu
        mov ah, 2
        int 21h
        
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
    main endp
end