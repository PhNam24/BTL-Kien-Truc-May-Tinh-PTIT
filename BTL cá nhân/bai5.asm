.model small
.stack 100h
.data
    tb1 db 'nhap chuoi: $'
    tb2 db 10, 13, 'chuoi viet thuong la: $'
    tb3 db 10, 13, 'chuoi viet hoa la: $'
    string db 100, ?, 101 dup(?)    ;chuoi nhap vao
.code
main proc
    
    mov ax, @data
    mov ds, ax
    
    ;nhap chuoi ky tu
    lea dx, tb1
    mov ah, 9
    int 21h
    
    lea dx, string
    mov ah, 0ah
    int 21h
    
    ;viet thuong
    lea dx, tb2
    mov ah, 9
    int 21h
    call vietThuong
    
    ;viet hoa
    lea dx, tb3
    mov ah, 9
    int 21h
    call vietHoa
    
    ;dung chuong trinh
    mov ah, 4ch
    int 21h
    
main endp

;ham viet thuong
vietThuong proc
    lea si, string + 1
    xor cx, cx
    mov cl, [si]
    inc si
    lap1:
        mov ah, 2
        mov dl, [si]
        cmp dl, 'A'
        jb tiep1
        cmp dl, 'Z'
        ja tiep1
        add dl, 32
        tiep1: inc si
        int 21h
     loop lap1
     ret
vietthuong endp

;ham viet hoa
vietHoa proc
    lea si, string + 1
    xor cx, cx
    mov cl, [si]
    inc si
    lap2:
        mov ah, 2
        mov dl, [si]
        cmp dl, 'a'
        jb tiep2
        cmp dl, 'z'
        ja tiep2
        sub dl, 32
        tiep2: inc si
        int 21h
    loop lap2
    ret
vietHoa endp
end