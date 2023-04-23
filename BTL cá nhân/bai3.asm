.model small
.stack 100h
.data 
    tb1 db "Nhap chuoi ky tu: $"
    tb2 db 10, 10, 13, "Chuoi ky tu vua nhap la: $"
    string db 256 dup("$") ;khai bao xau ky tu
.code 
    main proc
         mov ax, @data
         mov ds, ax
         
         ;nhap chuoi ky tu
         lea dx, tb1
         mov ah, 9
         int 21h
         
         mov ah, 10
         lea dx, string
         int 21h
         
         ;in ra chuoi ky tu
         lea dx, tb2
         mov ah, 9
         int 21h
         
         lea dx, string + 2
         mov ah, 9
         int 21h
         
         ;dung chuong trinh
         mov ah, 4ch
         int 21h
    main endp
end