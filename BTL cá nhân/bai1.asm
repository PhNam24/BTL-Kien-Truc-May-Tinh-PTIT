.model small
.stack 100h
.data
    Viet db "Xin chao!$"
    Anh db "Hello World!$"
    endl db 10, 10, 13, "$"
.code 
    main proc
        mov ax, @data
        mov ds, ax
        
        ;loi chao tieng Viet
        lea dx, Viet
        mov ah, 9
        int 21h
        
        ;in ra xuong dong
        lea dx, endl
        mov ah, 9
        int 21h
        
        ;loi chao tienh Anh
        lea dx, Anh
        mov ah, 9
        int 21h
        
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
    main endp
end