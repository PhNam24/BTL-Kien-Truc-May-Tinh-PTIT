.model small
.stack 100h
.data
    tb1 db 'nhap chuoi ky tu: $'
    tb2 db 10, 13, 'do dai cua chuoi ky tu tren la: $'
    string db 100 dup('$')
.code
main proc
    mov ax, @data
    mov ds, ax    
    ;nhap chuoi ky tu
    lea dx, tb1
    mov ah, 9
    int 21h    
    lea dx, string
    mov ah, 10                             
    int 21h    
    ;do dai chuoi ky tu
    lea dx, tb2
    mov ah, 9
    int 21h
    
    call chieuDai
    
    ;dung chuong trinh
    mov ah, 4ch
    int 21h
main endp
;ham tinh do dai chuoi
chieuDai proc 
    xor ax, ax            ;clear ax
    mov al, string + 1    ;chuyen chieu dai chuoi vao ax al 
    mov cx, 0             ;khoi tao bien dem cx = 0
    mov bx, 10            ;khoi tao so chia = 10 
    ;lap de dem
    lapDem:
        mov dx, 0         ;khoi tao phan du dx = 0
        div bx            ;lay ax al chia 10
        push dx           ;day phan du vao ngan xep
        inc cx            ;tang bien dem len 1
        cmp ax, 0         ;so sanh ax voi 0 vi ax luu thuong cua phep chia
        jnz lapDem        ;neu ax khac 0 thi lapDem
    ;lap de in kq
    lapIn:
        pop dx
        add dx, '0'
        mov ah, 2
        int 21h
    loop lapIn      
    ret
chieuDai endp
end